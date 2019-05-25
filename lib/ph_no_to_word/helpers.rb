# frozen_string_literal: true

# TODO: for future use
module PhNoToWord
  # helper module to expand functionalities
  module Helpers
    def configure
      yield(self) if block_given?
    end
  end
end