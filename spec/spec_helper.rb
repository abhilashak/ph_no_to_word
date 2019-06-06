# frozen_string_literal: true

if RUBY_VERSION >= '2.5.3'
  require 'simplecov'
  require 'coveralls'
  Coveralls.wear!

  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter,
                          Coveralls::SimpleCov::Formatter]

  SimpleCov.start do
    add_filter '/spec'
    minimum_coverage(90)
  end
end

require 'bundler/setup'
require 'ph_no_to_word'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
