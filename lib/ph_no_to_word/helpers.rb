# frozen_string_literal: true

# Helper
module PhNoToWord
  # helper module to expand functionalities
  module Helpers
    # Module methods
    module ClassMethods
      include Constants

      def self.extended(base)
        base.send(:include, Constants)
      end

      def first_wd?(word_no)
        word_no.zero?
      end

      def second_wd?(word_no)
        word_no == 1
      end

      def third_wd?(word_no)
        word_no == 2
      end

      def first_or_sec_wd?(word_no)
        first_wd?(word_no) || second_wd?(word_no)
      end

      # Compare two strings irrespective of case
      def cmp(line, str)
        return false unless line && str

        line.strip.casecmp(str.strip).zero?
      end

      # Checks the position is within the given array
      def inside_last_pos?(ary, pos)
        pos < ary.length
      end

      # Provides the filename to search for 10 charcter word
      def ten_chr_wd_filename(word)
        word[0..2] + FILE_EXT
      end

      # For word to search it should have minimum word length
      # and length of the words are not in forbidden list
      def valid_word?(word, pos)
        word.length >= MIN_WD_LENGTH && !FORBN_WD_LENS.include?(pos)
      end

      # Checks there is a room for another word within 10 character
      def can_accomdte_another_wd?(result)
        result.length <= MAX_WD_LEN
      end

      # Search for first word until position 6
      # Words with 7, 8 first wds will not counts
      # Checks for 10 character words are done at last separately
      def search_again_for_first_wd?(word_no, pos)
        first_wd?(word_no) && pos <= MAX_WD_LEN_INDEX
      end

      # Search for second and thrid word until all remaining positions
      def search_again_for_second_thrid_wd?(word_no, pos, ary)
        second_wd?(word_no) || third_wd?(word_no) && inside_last_pos?(ary, pos)
      end

      # if not scanned earlier for next word and word ary
      # must have min word length for searching the word,
      # then gives permission for searching the next word
      def search_for_nxt_wd?(scanned, wd_ary_len)
        !scanned && wd_ary_len >= MIN_WD_LENGTH
      end

      # If second word and length is less then to accomodate an another word,
      # then search for third word
      def stop_mth_with_nxt_wrd?(pos, wds)
        pos != :second || wds.length > MAX_WD_LEN
      end

      # sets the variables that stores the data within loops
      def set_data_stores
        @result           ||= Set.new
        @matching_wd_hash ||= { first: [], second: [], third: [] }
        @scanned_pos      ||= []
        nil
      end

      # reset the stored results data
      def reset_data_stores
        @result           = nil
        @matching_wd_hash = nil
        @scanned_pos      = nil
      end

      # provide the key according to first, second or third word
      def key_frm_word_no(word_no)
        case word_no
        when 0
          :first
        when 1
          :second
        when 2
          :third
        end
      end

      # Level 1: 3 char words
      # Level 2: > 3 char words
      # Level 3: 10 char words
      def filename_frm_lvl(str)
        case str.length
        when MIN_WD_LENGTH
          level    = 1
          filename = nil
        when PH_LENGTH
          level    = 3
          filename = str[0..2] + FILE_EXT
        else
          level    = 2
          filename = str[0..3] + FILE_EXT
        end
        [level, filename]
      end
    end

    extend ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
