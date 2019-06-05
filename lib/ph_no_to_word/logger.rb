# frozen_string_literal: true

# This modules helps to write into the log file
# Usage:
#   include PhNoToWord::Logger
#   def do_something
#     begin
#       # do something
#     rescue StandardError => e
#       log :error, e.message
#     end
#   end
module PhNoToWord
  module Logger
    # TODO
    # Log a PhNoToWord-specific line.
    # def log(level, message)
    #   File.open('error.log', 'a') do |f|
    #     f.write "#{level}: #{message}"
    #   end
    # end
  end
end
