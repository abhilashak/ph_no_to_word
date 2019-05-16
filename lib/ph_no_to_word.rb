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
require 'ph_no_to_word/error'
require 'ph_no_to_word/logger'
require 'ph_no_to_word/helpers'

# The base module that handles major methods
module PhNoToWord
  extend Error
  extend Logger
  extend Helpers

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

  # @param phone_no [String]
  # @return words [Array]
  def self.convert(phone_no = '')
    puts "Phone number provided is: #{phone_no}"
    raise RequiredArgumentMissingError, 'Please provide a phone number' if phone_no.blank?
    ph_numbers = phone_no.split(//)
    if (ph_numbers & FORBIDDEN_NOS).present?
      raise MalformattedArgumentError, 'Cannot contain 0 or 1 in the phone number'
    end
  end
end
