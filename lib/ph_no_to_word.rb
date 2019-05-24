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
  # PhNoToWord::convert "234"
  # add 2nd parameter: file_path = nil
  # and add `split_files(file_path)` for splitting the provided dictionary
  def self.convert(phone_no = '')
    puts "Phone number provided is: #{phone_no}"
    raise RequiredArgumentMissingError, ERRORS[:missing_ph] if phone_no.empty?

    ph_numbers = phone_no.split(//)
    unless (ph_numbers & FORBIDDEN_NOS).empty?
      raise MalformattedArgumentError, ERRORS[:malformed_ph_no]
    end

    ph_to_word_mapping = ph_numbers.map { |ph_no| NO_CHAR_MAP[ph_no.to_sym] }
    find_word(ph_to_word_mapping)
  end

  # finds the matching words and prints it
  # calls from 0 - 9 chars and finds the matching
  def self.find_word(char_ary = [], start = 0, str = '')
    loop_proc = proc do |ary, pos, match|
      (ary[pos] || []).each do |char|
        result = print_result(match + char) if pos > 1
        # call again if there is a scope of second word
        # if the word matches and have length of less than 7
        if result && result.length < MAX_FST_WD_LEN
          find_word(char_ary[result.length..-1], 0, '')
        end
        # call again until the last phone no reaches
        loop_proc.call(ary, pos + 1, match + char) if pos < PH_LENGTH
      end
    end

    loop_proc.call(char_ary, start, str)
  end

  # search matching word and print it
  def self.print_result(chars_to_match)
    result = search_word(chars_to_match)
    puts "====> #{result}" if result
    result
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
            :check_file_cnt_matches, :find_file_to_search, :print_result
  end
end
