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

# The base module that handles major methods
module PhNoToWord
  include Constants
  include Error
  extend Logger
  extend Helpers

  def self.extended(base)
    base.send(:include, Constants)
  end

  def self.included(base)
    class << base
      private :_pbt_polymorphic_orphans
      private :_pbt_nonpolymorphic_orphans
    end
  end

  # @param phone_no [String]
  # @return words [Array]
  # PhNoToWord::convert "234"
  def self.convert(phone_no = '', file_path = nil)
    split_files(file_path)
    puts "Phone number provided is: #{phone_no}"
    raise RequiredArgumentMissingError, ERRORS[:missing_ph] if phone_no.empty?

    ph_numbers = phone_no.split(//)
    unless (ph_numbers & FORBIDDEN_NOS).empty?
      raise MalformattedArgumentError, ERRORS[:malformed_ph_no]
    end

    ph_to_word_mapping = ph_numbers.map { |ph_no| NO_CHAR_MAP[ph_no.to_sym] }
    puts "ph_to_word_mapping: #{ph_to_word_mapping}"

    words = find_word(ph_to_word_mapping.first(3))
    words
  end

  # @param file_path [String]
  # Ex: file_path: /path/to/dictionary.txt
  def self.split_files(file_path)
    file_path ||= __dir__ + DEFAULT_DICTIONARY_FILE_PATH
    p file_path
    raise FileNotExists unless File.file?(file_path)

    File.open(file_path, 'r').each_line do |word|
      word.strip!
      # Create a file based on first 2 characters
      if word[0] && word[1] && word[2]
        write_to_file(word[0..2], word, 2)
      elsif word[0] && word[1]
        write_to_file(word[0..1], word)
      end
    end
  end

  # @param filename [String] word [String] level [Integer]
  # Ex: filename BAL, word BALL
  # Find the file with the filename provided and write the word to it
  #  if file not exists creates a new file with the filename
  #  level: 1, contains only 2 character words
  def self.write_to_file(filename, word, level = 1)
    folder_path = (level == 2 ? DEFAULT_WD_FILE_DIR_LVL_2 : DEFAULT_WORD_FILE_DIR)
    new_file_path = __dir__ + folder_path + "/#{filename.strip}.txt"
    new_file = if File.file?(new_file_path)
                 File.open(new_file_path, 'a')
               else
                 File.new(new_file_path, 'w')
               end
    new_file.puts word
    new_file.close
  end

  def self.find_word(char_ary = [])
    (0..3).each do |count|
      puts "char_ary: #{char_ary[count]}"
    end
  end

  class << self
    private :find_word, :write_to_file
  end
end
