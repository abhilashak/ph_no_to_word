# frozen_string_literal: true

require 'ph_no_to_word/error'

# included the error module and validation
module PhNoToWord
  # helper module to validating the phone number
  module Validator
    # Module methods
    module ClassMethods
      include Constants
      include Error

      def self.extended(base)
        base.send(:include, Constants)
      end

      # @param ph_no [String] ph_ary [Array]
      # Populate error if not a valid phone number given
      # Ex: ph_ary ["2", "2", "8", "2", "6", "6", "8", "6", "8", "7"]
      def validate(ph_no, ph_ary)
        raise RequiredArgumentMissingError, ERRORS[:missing_ph] if ph_no.empty?

        unless ph_no.length.eql?(PH_LENGTH)
          raise MalformattedArgumentError, ERRORS[:ph_length]
        end
        return if (ph_ary & FORBIDDEN_NOS).empty?

        raise MalformattedArgumentError, ERRORS[:malformed_ph_no]
      end
    end

    extend ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
