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
  # Add 2nd parameter: file_path = nil
  # And add `split_files(file_path)` for splitting the provided dictionary
  def self.convert(phone_no = '')
    raise RequiredArgumentMissingError, ERRORS[:missing_ph] if phone_no.empty?

    ph_numbers = phone_no.split(//)
    unless (ph_numbers & FORBIDDEN_NOS).empty?
      raise MalformattedArgumentError, ERRORS[:malformed_ph_no]
    end

    ph_to_word_mapping = ph_numbers.map { |ph_no| NO_CHAR_MAP[ph_no.to_sym] }
    result = find_word(ph_to_word_mapping)
    map_num_to_word(result, ph_numbers)
    nil
  end

  # Position the words matched to corresponding phone number
  # @param wd_ary [Set] ph_ary [Array] parent_wd [String]
  # Ex: ph_ary ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
  # Ex: wd_ary #<Set: {"MOT", "OPT", "PUB", "PUCK", "QUA", "RUB", "RUCK"}>
  def self.map_num_to_word(wd_ary, ph_ary, parent_wd = '', level = 1, wd_hash = {})
    wd_ary.each do |wd|
      wd_hash = arrange_wds(wd_hash, level, wd)
      total_len = (parent_wd + wd).length
      full_mapping_to_wd(parent_wd + wd, ph_ary, wd_hash) if total_len == PH_LENGTH
      next if total_len > MAX_FST_WD_LEN

      map_num_to_word(wd_ary, ph_ary, parent_wd + wd, level + 1, wd_hash) if level < MAXIMUM_WDS
    end
  end

  # Add first, second and third words in order to display
  # @param wd_hash [Hash] level [Integer] wd [String]
  def self.arrange_wds(wd_hash, level, wd)
    case level
    when 1
      wd_hash[:first] = wd
      wd_hash[:third] = wd_hash[:second] = nil if wd.length > MAX_FST_WD_LEN
    when 2
      wd_hash[:second] = wd
      wd_hash[:third] = nil if (wd_hash[:first] + wd).length > MAX_FST_WD_LEN
    when 3
      wd_hash[:third] = wd
    end
    wd_hash
  end

  # Checks each phone number against the respective word
  # Ex: ph_numbers ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
  # Ex: wd_ary     ["c", "a", "t", "a", "m", "o", "u", "n", "t", "s"]
  def self.full_mapping_to_wd(word, ph_numbers, disply_wrd)
    word_ary = word.split(//)
    ph_numbers.each_with_index do |number, index|
      return false unless NO_CHAR_MAP[number.to_sym].include?(word_ary[index].downcase)
    end
    puts disply_wrd.values.compact.join(', ').downcase
  end

  # finds the matching words and prints it
  # calls from 0 - 9 chars and finds the matching
  def self.find_word(char_ary = [], start = 0, str = '')
    @result ||= Set.new
    loop_phone = proc do |ary, pos, match|
      (ary[pos] || []).each do |char|
        result = print_result(match + char) if pos > 1
        @result.add(result) if result
        find_next_word(char_ary, result)
        # call again until the last phone no reaches
        loop_phone.call(ary, pos + 1, match + char) if pos < (PH_LENGTH - 1)
      end
    end
    loop_phone.call(char_ary, start, str)
    @result
  end

  # call again if there is a scope of second word
  # if the word matches and have length of less than 7
  def self.find_next_word(char_ary, result)
    return unless result && result.length <= MAX_FST_WD_LEN

    find_word(char_ary[result.length..-1], 0, '')
  end

  # search matching word and print it
  def self.print_result(chars_to_match)
    search_word(chars_to_match)
  end

  # finds the word with first, second and third character
  # @param str [String]
  # Level 1: 3 char words
  # Level 2: > 3 char words
  def self.search_word(str)
    level = (str.length == MIN_WD_LENGTH ? 1 : 2)
    # Ex: str acfdrt
    filename = if str.length > MAX_SPLIT_DEPTH
                 str[0..MAX_SPLIT_DEPTH - 1] + FILE_EXT
               else
                 # Ex: str asde, act, aem
                 str + FILE_EXT
               end
    new_file_path = find_file_to_search(level, filename)
    return nil unless File.file?(new_file_path)

    word_found = check_file_cnt_matches(new_file_path, str)
    word_found
  end

  # if level is 1, search in file three_char_wrds
  # else search in file with name of first 4 char wrd
  def self.find_file_to_search(lvl, filename)
    file_path = if lvl == 1
                  word_file_folder_path(lvl) + '/' + THREE_CHAR_FILE
                else
                  word_file_folder_path(lvl) + '/' + filename
                end
    file_path
  end

  # @param file_path [String] str [String]
  # Ex: file_path /path/to/file/act.txt, str: acr
  def self.check_file_cnt_matches(file_path, str)
    word_found = nil
    File.open(file_path, 'r') do |f|
      f.each_line do |line|
        # exit loop if finds the str from dictionary
        if line.strip.casecmp(str).zero?
          word_found = line.strip
          break
        end
      end
    end
    word_found
  end

  class << self
    private :find_word, :write_to_file, :search_word, :word_file_folder_path,
            :check_file_cnt_matches, :find_file_to_search, :print_result,
            :arrange_wds, :find_next_word
  end
end
