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
  include SplitDictionary
  include Error
  extend Logger
  extend Helpers

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
    matching_wd_hash = search_in_possible_wds(ph_to_word_mapping)
    reset_atrributes
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
  # Ex: ph_chars  [["a", "b", "c"], ["a", "b", "c"], ["t", "u", "v"],....]]
  # finds the matching words and prints it, calls from 0 - 9 chars and finds 
  # the matching in first, second and third positions
  # word_no: 0, 1, 2 (first, second and third words)
  def self.search_in_possible_wds(ph_chars = [], pos = 0, match = '', word_no = 0)
    @result ||= Set.new
    @matching_wd_hash ||= { first: [], second: [], third: [] }
    @scanned_pos ||= []

    (ph_chars[pos] || []).each do |char|
      wd_to_search = match + char

      # search the word if the characters has min length to become a WORD
      # And don't need to search at positions 7, 8 as even if the word is present
      # we cannot make second word to fulfil matching full ph no to words
      if wd_to_search.length >= MIN_WD_LENGTH && ![7, 8].include?(pos)
        result = search_for_wd_match(wd_to_search)

        if result
          @result.add(result)

          case word_no
          when 0
            already_scanned = @matching_wd_hash[:first].map(&:size).include?(result.length)
            @matching_wd_hash[:first] << result
          when 1
            already_scanned = @matching_wd_hash[:second].map(&:size).include?(result.length)
            @matching_wd_hash[:second] << result
          when 2
            @matching_wd_hash[:third] << result
          end

          if result.length <= MAX_WD_LEN
            if word_no == 0
              second_wd_ary = ph_chars[result.length..-1]
              if !already_scanned && second_wd_ary.length >= MIN_WD_LENGTH
                search_in_possible_wds(second_wd_ary, 0, '', word_no + 1)
              end
            elsif word_no == 1
              third_wd_ary = ph_chars[result.length..-1]
              if !already_scanned && third_wd_ary.length >= MIN_WD_LENGTH
                search_in_possible_wds(third_wd_ary, 0, '', word_no + 1)
              end
            end

          end
        end
      end

      if word_no == 0
        search_in_possible_wds(ph_chars, pos + 1, wd_to_search, word_no) if pos <= 6
      elsif word_no == 1
        search_in_possible_wds(ph_chars, pos + 1, wd_to_search, word_no) if pos < ph_chars.length
      elsif word_no == 2
        search_in_possible_wds(ph_chars, pos + 1, wd_to_search, word_no) if pos < ph_chars.length
      end
    end

    @matching_wd_hash
  end

  # reset the stored results data
  def self.reset_atrributes
    @result = nil
    @matching_wd_hash = nil
    @scanned_pos = nil
  end

  # @param ph_mapped_chr_ary [Array] start [Integer] str [String]
  # Ex: ph_mapped_chr_ary  [["a", "b", "c"], ["a", "b", "c"], ["t", "u", "v"],....]]
  # finds the matching words and prints it
  # calls from 0 - 9 chars and finds the matching
  # level: 1, 2, 3 (first, second and third character)
  # def self.find_word(ph_mapped_chr_ary = [], start = 0, str = '', level = 0)
  #   @result ||= Set.new
  #   @matching_wd_hash ||= { first: [], second: [], third: [] }
  #   @scanned_pos ||= []

  #   loop_phone = proc do |ary, pos, match, lvl|
  #     (ary[pos] || []).each do |char|
  #       result = search_for_wd_match(match + char) if pos >= WD_STARTS_AT_INDEX

  #       @result.add(result) if result
  #       if result
  #         case lvl
  #         when 0
  #           @matching_wd_hash[:first] << result
  #         when 1
  #           @matching_wd_hash[:second] << result
  #         when 2
  #           @matching_wd_hash[:third] << result
  #         end
  #       end
  #       # call again if there is a scope of second word
  #       # if the word matches and have length of less than 7
  #       if result && result.length <= MAX_WD_LEN && !@scanned_pos.include?(result.length)
  #         puts "@scanned_pos: #{@scanned_pos}"
  #         puts "lvl: #{lvl}"
  #         find_word(ph_mapped_chr_ary[result.length..-1], 0, '', lvl + 1)
  #         @scanned_pos << result.length
  #       end
  #       # find_next_word(ph_mapped_chr_ary, result)

  #       # puts "pos: #{pos}"
  #       loop_phone.call(ary, pos + 1, match + char, lvl) if within_ph_length(pos)
  #     end
  #   end

  #   loop_phone.call(ph_mapped_chr_ary, start, str, level)
  #   @result
  # end

  # def self.within_ph_length(pos)
  #   pos < (PH_LENGTH - 1)
  # end

  # call again if there is a scope of second word
  # if the word matches and have length of less than 7
  # def self.find_next_word(ph_mapped_chr_ary, result)
  #   return unless result && result.length <= MAX_WD_LEN

  #   find_word(ph_mapped_chr_ary[result.length..-1], 0, '')
  # end

  # search matching word and print it
  # def self.print_result(chars_to_match)
  #   search_for_wd_match(chars_to_match)
  # end

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

  # Compare two strings irrespective of case
  def self.cmp(line, str)
    return false unless line && str

    line.strip.casecmp(str.strip).zero?
  end

  class << self
    private :cmp, :check_file_cnt_matches, :find_file_to_search,
            :search_for_wd_match, :reset_atrributes, :search_in_possible_wds,
            :wds_satisfy_pos?, :map_num_to_word_hash, :validate
  end
end
