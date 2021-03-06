# frozen_string_literal: true

# module that provides all the constants
module PhNoToWord
  module Constants
    ERRORS = {
      missing_ph: 'Please provide a phone number',
      ph_length: 'Please provide 10 digit phone number',
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
    FORBN_WD_LENS = %w[7 8].freeze
    MAX_SPLIT_DEPTH = 4
    MIN_WD_LENGTH = MAXIMUM_WDS = 3
    WD_STARTS_AT_INDEX = 2
    FILE_EXT = '.txt'
    THREE_CHAR_FILE = 'three_char_wrds' + FILE_EXT
    PH_LENGTH = 10
    MAX_WD_LEN = 7
    MAX_WD_LEN_INDEX = 6
    DEFAULT_WORD_FILES_PATH = '/word_files'
    DEFAULT_WORD_FILE_DIR = DEFAULT_WORD_FILES_PATH + '/level_1'
    DEFAULT_WD_FILE_DIR_LVL_2 = DEFAULT_WORD_FILES_PATH + '/level_2'
    DEFAULT_WD_FILE_DIR_LVL_3 = DEFAULT_WORD_FILES_PATH + '/level_3'
    DEFAULT_DICTIONARY_FILE_PATH = DEFAULT_WORD_FILES_PATH + '/dictionary' + FILE_EXT
  end
end
