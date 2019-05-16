module PhNoToWord
  module Helpers
    def configure
      yield(self) if block_given?
    end
  end
end