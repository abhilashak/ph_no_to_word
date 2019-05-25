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
  # And add `split_files(file_path)` for splitting the provided dictionary file
  def self.convert(phone_no = '')
    ph_numbers = phone_no.split(//)
    validate phone_no, ph_numbers

    ph_to_word_mapping = ph_numbers.map { |ph_no| NO_CHAR_MAP[ph_no.to_sym] }

    result = find_word(ph_to_word_mapping)
    map_num_to_word(result, ph_numbers)
  end

  # @param phone_no [String]
  # Populate error if not a valid phone number given
  def self.validate(phone_no, ph_numbers)
    raise RequiredArgumentMissingError, ERRORS[:missing_ph] if phone_no.empty?

    unless phone_no.length.eql?(PH_LENGTH)
      raise MalformattedArgumentError, ERRORS[:ph_length]
    end
    return if (ph_numbers & FORBIDDEN_NOS).empty?

    raise MalformattedArgumentError, ERRORS[:malformed_ph_no]
  end

  # Position the words matched to corresponding phone number
  # @param wd_ary [Set] ph_ary [Array] parent_wd [String] level [Integer] wd_hash [Hash]
  # Ex: ph_ary ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
  # Ex: wd_ary #<Set: {"MOT", "OPT", "PUB", "PUCK", "QUA", "RUB", "RUCK"}>
  # wd_hash is a tricky implementation that is using to add the commas in
  #   between the words found in the result, should try to avoid in future
  # Ex: level 1, 2, 3 because Maximum 3 words can only contain in the result
  # Ex: wd_hash { :first => "asasa", :second => "dfdfdf", :third => "ddfdfdf"}
  def self.map_num_to_word(wd_ary, ph_ary, parent_wd = '', level = 1, wd_hash = {})
    @matching_wd_ary ||= []

    wd_ary.each do |wd|
      wd_hash = arrange_result(wd_hash, level, wd)
      total_len = (parent_wd + wd).length

      if total_len == PH_LENGTH
        result = full_mapping_to_wd(parent_wd + wd, ph_ary, wd_hash)
        @matching_wd_ary << result if result
      end

      next if total_len > MAX_FST_WD_LEN

      if level < MAXIMUM_WDS
        map_num_to_word(wd_ary, ph_ary, parent_wd + wd, level + 1, wd_hash)
      end
    end

    @matching_wd_ary
  end

  # Add first, second and third words in order to display
  # @param wd_hash [Hash] level [Integer] wd [String]
  def self.arrange_result(wd_hash, level, word)
    case level
    when 1
      wd_hash[:first] = word
      wd_hash[:third] = wd_hash[:second] = nil if word.length > MAX_FST_WD_LEN
    when 2
      wd_hash[:second] = word
      wd_hash[:third] = nil if (wd_hash[:first] + word).length > MAX_FST_WD_LEN
    when 3 then wd_hash[:third] = word
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

    disply_wrd.values.compact.join(', ').downcase
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
  # Ex: str acfdrt in if condition
  # Ex: str asde, act, aem in else condition
  def self.search_word(str)
    level = (str.length == MIN_WD_LENGTH ? 1 : 2)
    filename = if str.length > MAX_SPLIT_DEPTH
                 str[0..MAX_SPLIT_DEPTH - 1] + FILE_EXT
               else
                 str + FILE_EXT
               end

    new_file_path = find_file_to_search(level, filename)
    return nil unless File.file?(new_file_path)

    check_file_cnt_matches(new_file_path, str)
  end

  # if level is 1, search in file three_char_wrds
  # else search in file with name of first 4 char wrd
  def self.find_file_to_search(lvl, filename)
    return (word_file_folder_path(lvl) + '/' + THREE_CHAR_FILE) if lvl == 1

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
    private :find_word, :write_to_file, :search_word, :word_file_folder_path,
            :check_file_cnt_matches, :find_file_to_search, :print_result,
            :arrange_result, :find_next_word, :cmp
  end
end
