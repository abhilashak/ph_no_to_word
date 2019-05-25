# frozen_string_literal: true

require 'ph_no_to_word/constants'
require 'ph_no_to_word/error'

# module that provides all the constants
module PhNoToWord
  # this module splits the dictionary file into pieces
  module SplitDictionary
    # Module methods
    module ClassMethods
      include Error
      include Constants

      def self.extended(base)
        base.send(:include, Constants)
      end

      # @param file_path [String]
      # Ex: file_path: /path/to/dictionary.txt
      # if condition Create a file based on first 4 characters
      # else condition Create a file based on first 3 characters
      def split_files(file_path)
        remove_all_files

        file_path ||= __dir__ + DEFAULT_DICTIONARY_FILE_PATH
        raise FileNotExists unless File.file?(file_path)

        File.open(file_path, 'r').each_line do |word|
          word.strip!

          if word.length > MIN_WD_LENGTH
            write_to_file(word[0..3], word)
          elsif word.length == MIN_WD_LENGTH
            write_to_file(word, word, 1)
          end
        end
      end

      # Removes all the files that created by splitting the dictionary
      def remove_all_files
        [DEFAULT_WORD_FILE_DIR,
         DEFAULT_WD_FILE_DIR_LVL_2].each do |folder|
          directory_name = "#{__dir__}#{folder}"

          if File.file?(directory_name)
            FileUtils.rm_f Dir.glob("#{directory_name}/*")
          else
            FileUtils.mkdir_p directory_name
          end
        end
      end

      # @param filename [String] word [String] level [Integer]
      # Ex: filename BAL, word BALL
      # Find the file with the filename provided and write the word to it
      #  if file not exists creates a new file with the filename
      # Level 1: text files with 3 char length filename
      # Level 2: text files with 4 char length filename
      def write_to_file(filename, word, level = 2)
        folder_path = word_file_folder_path(level)

        new_file_path = if level == 1
                          folder_path + '/' + THREE_CHAR_FILE
                        else
                          folder_path + "/#{filename.strip.downcase}" + FILE_EXT
                        end

        new_file = if File.file?(new_file_path)
                     File.open(new_file_path, 'a')
                   else
                     File.new(new_file_path, 'w')
                   end

        new_file.puts word
        new_file.close
      end

      # Finds the folder path according to the level
      # Level 1: text files with 3 char length filename
      # Level 2: text files with 4 char length filename
      def word_file_folder_path(level = 2)
        return (__dir__ + DEFAULT_WORD_FILE_DIR) if level == 1

        __dir__ + DEFAULT_WD_FILE_DIR_LVL_2
      end
    end

    extend ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
