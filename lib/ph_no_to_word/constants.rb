# frozen_string_literal: true

# module that provides all the constants
module PhNoToWord
  module Constants
    ERRORS = {
      missing_ph: 'Please provide a phone number',
      malformed_ph_no: 'Cannot contain 0 or 1 in the phone number'
    }.freeze
    NO_CHAR_MAP = {
      '2': %w[a b c],
      '3': %w[d e f],
      '4': %w[g h i],
      '5': %w[j k l],
      '6': %w[m n o],
      '7': %w[p q r s],
      '8': %w[t u v],
      '9': %w[w x y z]
    }.freeze
    FORBIDDEN_NOS = %w[0 1].freeze
    MAX_SPLIT_DEPTH = 4
    PH_LENGTH = 9
    DEFAULT_WORD_FILES_PATH = '/ph_no_to_word/word_files'
    DEFAULT_WORD_FILE_DIR = DEFAULT_WORD_FILES_PATH + '/level_1'
    DEFAULT_WD_FILE_DIR_LVL_2 = DEFAULT_WORD_FILES_PATH + '/level_2'
    DEFAULT_DICTIONARY_FILE_PATH = DEFAULT_WORD_FILES_PATH + '/dictionary_sample.txt'
  end
end
