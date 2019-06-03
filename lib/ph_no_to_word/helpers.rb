# frozen_string_literal: true

# TODO: for future use
module PhNoToWord
  # helper module to expand functionalities
  module Helpers
    # Module methods
    module ClassMethods
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

      # Compare two strings irrespective of case
      def cmp(line, str)
        return false unless line && str

        line.strip.casecmp(str.strip).zero?
      end

      # Checks the position is within the given array
      def inside_last_pos?(ary, pos)
        pos < ary.length
      end
    end

    extend ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
