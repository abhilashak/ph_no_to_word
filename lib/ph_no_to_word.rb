# frozen_string_literal: true

# ph_no_to_word allows given 10 character phone number to convert into a word
# that is contained in a dictionary.
# The phone number should not contain 0 or 1. The matching words contain atleast
# characters.

# Author:: Abhilash A K
# Copyright:: Copyright (c) 2019
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

# 2282668687 returns a (long) list with at least these word combinations:
# * catamounts
# * acta, mounts
# * act, amounts
# * act, contour
# * cat, boot, our
require 'ph_no_to_word/version'
require 'ph_no_to_word/constants'
require 'ph_no_to_word/error'
require 'ph_no_to_word/logger'
require 'ph_no_to_word/helpers'
require 'ph_no_to_word/split_dictionary'
require 'fileutils'
require 'set'

# The base module that handles major methods
module PhNoToWord
  include Constants
  include Helpers
  include SplitDictionary
  include Error
  extend Logger

  def self.extended(base)
    base.send(:include, Constants)
  end

  # @param phone_no [String]
  # @return words [Array]
  # Ex: PhNoToWord::convert "2282668687"
  # And add `split_files(nil)` in line 1 for splitting the dictionary file
  def self.convert(phone_no = '')
    ph_numbers = phone_no.split(//)
    validate phone_no, ph_numbers

    ph_to_word_mapping = ph_numbers.map { |ph_no| NO_CHAR_MAP[ph_no.to_sym] }
    matching_wd_hash = search_for_wds(ph_to_word_mapping)
    reset_data_stores
    map_num_to_word_hash(matching_wd_hash, ph_numbers)
  end

  # @param phone_no [String] ph_numbers [Array]
  # Populate error if not a valid phone number given
  # Ex: ph_numbers ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
  def self.validate(phone_no, ph_numbers)
    raise RequiredArgumentMissingError, ERRORS[:missing_ph] if phone_no.empty?

    unless phone_no.length.eql?(PH_LENGTH)
      raise MalformattedArgumentError, ERRORS[:ph_length]
    end
    return if (ph_numbers & FORBIDDEN_NOS).empty?

    raise MalformattedArgumentError, ERRORS[:malformed_ph_no]
  end

  # Combaine the first second and third words to form the result
  # @param wd_hash [Hash] ph_numbers [Array]
  # Ex: ph_numbers ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
  # Ex: wd_hash { :first => "act", :second => "amounts", :third => nil}
  def self.map_num_to_word_hash(wd_hash = {}, ph_numbers)
    full_match = []
    ten_char_seached_files = []

    wd_hash[:first].each do |first_wd|
      wd_hash[:second].each do |second_wd|
        first_two_wds = first_wd + second_wd

        if first_two_wds.length == 10 && wds_satisfy_pos?(0, first_two_wds, ph_numbers)
          full_match << "#{first_wd}, #{second_wd}".downcase
        end

        if first_two_wds.length <= 7
          wd_hash[:third].each do |trd_wd|
            three_wd = first_two_wds + trd_wd

            if three_wd.length == 10 && wds_satisfy_pos?(0, first_wd + second_wd + trd_wd, ph_numbers)
              full_match << "#{first_wd}, #{second_wd}, #{trd_wd}".downcase
            end
          end
        end
      end

      # Find 10 character words that matches the given phone number
      filename = first_wd[0..2] + FILE_EXT
      new_file_path = find_file_to_search(3, filename)
      if File.file?(new_file_path) && !ten_char_seached_files.include?(filename)
        File.open(new_file_path, 'r') do |f|
          f.each_line { |line| (full_match << line.strip.downcase ) && break if wds_satisfy_pos?(0, line, ph_numbers) }
        end
        ten_char_seached_files << filename
      end
    end

    full_match
  end

  # @param first_pos [Integer] second_wd [String]
  # Checks each respective word  against the phone number is positioned correct
  # Ex: first_pos: 3, second_wd: amount
  # Ex: ph_numbers ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
  # second_wd Poistion like ["--", "--", "--", "a", "m", "o", "u", "n", "t", "--"]
  def self.wds_satisfy_pos?(first_pos, row_wds, ph_numbers)
    row_wds_ary = row_wds.split(//)
    final_pos = first_pos + row_wds.length - 1

    ph_numbers[first_pos..final_pos].each_with_index do |number, index|
      return false unless NO_CHAR_MAP[number.to_sym].include?(row_wds_ary[index].downcase)
    end
    true
  end

  # @param ph_chars [Array] pos [Integer] match [String] word_no [Integer]
  # finds the matching words and prints it, calls from 0 - 9 chars and finds
  # the matching in first, second and third positions
  # Ex: ph_chars  [["a", "b", "c"], ["a", "b", "c"], ["t", "u", "v"],....]]
  # Ex: word_no: 0, 1, 2 (first, second and third words)
  # Ex: match: acts, acr, catamou
  # Ex: pos: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
  def self.search_for_wds(ph_chars = [], pos = 0, match = '', word_no = 0)
    set_data_stores
    (ph_chars[pos] || []).each do |char|
      wd_to_search = match + char

      search_it!(wd_to_search, pos, word_no, ph_chars)
      scan_with_nxt_char(word_no, ph_chars, pos, wd_to_search)
    end
    @matching_wd_hash
  end

  # search the word if the combained characters has min WORD length
  # and don't need to search at positions 7, 8 as even if the word is present
  # we cannot make second word to fulfil matching full ph no to words
  def self.search_it!(wd_to_search, pos, word_no, ph_chars)
    return unless wd_to_search.length >= MIN_WD_LENGTH && ![7, 8].include?(pos)

    result = search_for_wd_match(wd_to_search)
    return unless result

    already_scanned = already_scanned_for_nxt_wd?(word_no, result)
    add_result_to_store(result, word_no)
    return unless result.length <= MAX_WD_LEN

    nxt_wd_ary = ph_chars[result.length..-1]
    search_wd_in_nxt_pos(word_no, already_scanned, nxt_wd_ary)
  end

  # Checks there is a need for search next word. If yes search for it
  def self.search_wd_in_nxt_pos(wd_no, scanned, wd_ary)
    return unless first_or_sec_wd?(wd_no) && search_for_nxt_wd?(scanned, wd_ary.length)

    search_for_wds(wd_ary, 0, '', wd_no + 1)
  end

  # if not scanned earlier for next word and word must have min word length
  # then gives permission for searching the next word
  def self.search_for_nxt_wd?(scanned, wd_ary_len)
    !scanned && wd_ary_len >= MIN_WD_LENGTH
  end

  # Adds the matching word to result store and position store
  def self.add_result_to_store(result, word_no)
    @result.add(result)
    return unless first_or_sec_wd?(word_no) || third_wd?(word_no)

    @matching_wd_hash[key_frm_word_no(word_no)] << result
  end

  def self.already_scanned_for_nxt_wd?(word_no, result)
    return unless first_or_sec_wd?(word_no)

    key = first_wd?(word_no) ? :first : :second
    @matching_wd_hash[key].map(&:size).include?(result.length)
  end

  # Scan the dictionary words with next character from the mapped ph no
  def self.scan_with_nxt_char(word_no, ph_chars, pos, wd_to_search)
    return unless search_again_for_first_wd?(word_no, pos) ||
                  search_again_for_second_thrid_wd?(word_no, pos, ph_chars)

    search_for_wds(ph_chars, pos + 1, wd_to_search, word_no)
  end

  # Search for first word until position 6
  # Words with 7, 8 first wds will not counts
  # Checks for 10 character words are done at last separately
  def self.search_again_for_first_wd?(word_no, pos)
    first_wd?(word_no) && pos <= MAX_WD_LEN_INDEX
  end

  # Search for second and thrid word until all remaining positions
  def self.search_again_for_second_thrid_wd?(word_no, pos, ph_chars)
    second_wd?(word_no) || third_wd?(word_no) && inside_last_pos?(ph_chars, pos)
  end

  # sets the variables that stores the data within loops
  def self.set_data_stores
    @result           ||= Set.new
    @matching_wd_hash ||= { first: [], second: [], third: [] }
    @scanned_pos      ||= []
    nil
  end

  # reset the stored results data
  def self.reset_data_stores
    @result           = nil
    @matching_wd_hash = nil
    @scanned_pos      = nil
  end

  # finds the word with first, second and third character
  # @param str [String]
  # Level 1: 3 char words
  # Level 2: > 3 char words
  # Ex: str acfdrt in if condition
  # Ex: str asde, act, aem in else condition
  def self.search_for_wd_match(str)
    filename = nil
    case str.length
    when MIN_WD_LENGTH
      level = 1
    when PH_LENGTH
      level = 3
      filename = str[0..2] + FILE_EXT
    else
      level = 2
      filename = str[0..3] + FILE_EXT
    end

    new_file_path = find_file_to_search(level, filename)
    return nil unless File.file?(new_file_path)

    check_file_cnt_matches(new_file_path, str)
  end

  # if level is 1, search in file three_char_wrds
  # if level is 3, search in file ten_char_wds
  # else search in file with name of first 4 char wrd
  def self.find_file_to_search(lvl, filename)
    return (word_file_folder_path(lvl) + '/' + THREE_CHAR_FILE) if lvl == 1

    # return (word_file_folder_path(lvl) + '/' + TEN_CHAR_FILE)   if lvl == 3
    word_file_folder_path(lvl) + '/' + filename
  end

  # @param file_path [String] str [String]
  # Ex: file_path /path/to/file/act.txt, str: acr
  def self.check_file_cnt_matches(file_path, str)
    word_found = nil
    File.open(file_path, 'r') do |f|
      f.each_line { |line| (word_found = line.strip) && break if cmp(line, str) }
    end
    word_found
  end

  class << self
    private :cmp, :check_file_cnt_matches, :find_file_to_search,
            :search_for_wd_match, :reset_data_stores, :search_for_wds,
            :wds_satisfy_pos?, :map_num_to_word_hash, :validate, :set_data_stores
  end
end
