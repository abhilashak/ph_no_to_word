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
require 'ph_no_to_word/validator'
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
  include Validator
  extend Logger

  def self.extended(base)
    base.send(:include, Constants)
  end

  # @param ph_number [String]
  # @return words [Array]
  # Ex: PhNoToWord::convert '2282668687'
  # And add `split_files(nil)` in line 1 for splitting the dictionary file
  def self.convert(ph_number = '')
    ph_ary = ph_number.split(//)
    validate ph_number, ph_ary

    ph_to_word_mapping = ph_ary.map { |ph_no| NO_CHAR_MAP[ph_no.to_sym] }

    matching_wd_hash = search_for_wds(ph_to_word_mapping)

    reset_data_stores
    map_num_to_word_hash(matching_wd_hash, ph_ary)
  end

  # Combaine the first second and third words to form the result
  # @param wd_hash [Hash] ph_ary [Array]
  # Ex: ph_ary ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
  # Ex: wd_hash { :first => "act", :second => "amounts", :third => nil}
  def self.map_num_to_word_hash(wd_hash = {}, ph_ary)
    matches = []
    chkd_ten_chr_fls = []

    wd_hash[:first].each do |first_wd|
      matches = match_with_nxt_wd(:second, wd_hash, ph_ary, matches, first_wd)

      matches, chkd_ten_chr_fls = find_ten_chr_wds(first_wd,
                                                   ph_ary,
                                                   chkd_ten_chr_fls,
                                                   matches)
    end
    matches
  end

  # combaine the word with next word and check matches the ph number
  # If the word is second matched word and less than max wd length
  # then match it with third word
  def self.match_with_nxt_wd(pos, wd_hash, ph_ary, matches, *wds)
    wd_hash[pos].each do |wd|
      matches << wd_matches_to_ph(ph_ary, wds + [wd])
      next if pos != :second || (wds.join + wd).length > MAX_WD_LEN

      matches = match_with_nxt_wd(:third, wd_hash, ph_ary, matches, wds + [wd])
    end
    matches.compact
  end

  # If the provided word to match with full phone number,
  # it should match with phone number mapped character and have length 10
  def self.wd_matches_to_ph(ph_ary, *wrds)
    return unless wrds.join.length == PH_LENGTH && wds_satisfy_pos?(0, wrds.join, ph_ary)

    wrds.join(', ').downcase
  end

  # Find 10 character words that matches the given phone number
  # files_ary: Keeping track of already searched files
  def self.find_ten_chr_wds(fst_wd, ph_ary, files_ary, matcd_ary)
    filename = ten_chr_wd_filename(fst_wd)
    new_file_path = find_file_to_search(3, filename)

    if File.file?(new_file_path) && !files_ary.include?(filename)
      File.open(new_file_path, 'r') do |f|
        f.each_line { |line| (matcd_ary << line.strip.downcase) && break if wds_satisfy_pos?(0, line, ph_ary) }
      end

      files_ary << filename
    end

    [matcd_ary, files_ary]
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
  def self.search_it!(wrd, pos, word_no, ph_chars)
    return unless valid_word?(wrd, pos)

    result = search_for_wd_match(wrd)
    return unless result

    already_scanned = already_scanned_for_nxt_wd?(word_no, result)
    add_result_to_store(result, word_no)
    return unless can_accomdte_another_wd?(result)

    nxt_wd_ary = ph_chars[result.length..-1]
    search_wd_in_nxt_pos(word_no, already_scanned, nxt_wd_ary)
  end

  # Checks there is a need for search next word. If yes search for it
  def self.search_wd_in_nxt_pos(wd_no, scanned, wd_ary)
    return unless first_or_sec_wd?(wd_no) && search_for_nxt_wd?(scanned, wd_ary.length)

    search_for_wds(wd_ary, 0, '', wd_no + 1)
  end

  # Adds the matching word to result store and position store
  def self.add_result_to_store(result, word_no)
    @result.add(result)
    return unless first_or_sec_wd?(word_no) || third_wd?(word_no)

    @matching_wd_hash[key_frm_word_no(word_no)] << result
  end

  # Checks already scanned for next word with same positions by checking
  # previous result length, for the results with same length don't need to
  # search again for word from next positions 
  def self.already_scanned_for_nxt_wd?(word_no, result)
    return unless first_or_sec_wd?(word_no)

    key = first_wd?(word_no) ? :first : :second
    @matching_wd_hash[key].map(&:size).include?(result.length)
  end

  # Scan the dictionary words with next character from the mapped phone number
  def self.scan_with_nxt_char(word_no, ph_chars, pos, wd_to_search)
    return unless search_again_for_first_wd?(word_no, pos) ||
                  search_again_for_second_thrid_wd?(word_no, pos, ph_chars)

    search_for_wds(ph_chars, pos + 1, wd_to_search, word_no)
  end

  # finds the word with first, second and third character
  # @param str [String]
  # Ex: str asde, act, aem in else condition
  def self.search_for_wd_match(str)
    level, filename = filename_frm_lvl(str)
    new_file_path = find_file_to_search(level, filename)
    return nil unless File.file?(new_file_path)

    check_file_cnt_matches(new_file_path, str)
  end

  # if level is 1, search in file three_char_wrds
  # if level is 3, search in file ten_char_wds
  # else search in file with name of first 4 char wrd
  def self.find_file_to_search(lvl, filename)
    return (word_file_folder_path(lvl) + '/' + THREE_CHAR_FILE) if lvl == 1

    word_file_folder_path(lvl) + '/' + filename
  end

  # @param file_path [String] str [String]
  # Ex: file_path /path/to/file/act.txt, str: acr
  def self.check_file_cnt_matches(file_path, str)
    wd_found = nil
    File.open(file_path, 'r') do |f|
      f.each_line { |line| (wd_found = line.strip) && break if cmp(line, str) }
    end
    wd_found
  end

  class << self
    private :cmp, :check_file_cnt_matches, :find_file_to_search,
            :search_for_wd_match, :reset_data_stores, :search_for_wds,
            :wds_satisfy_pos?, :map_num_to_word_hash, :validate,
            :set_data_stores
  end
end
