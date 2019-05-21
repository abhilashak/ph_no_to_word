
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ph_no_to_word/version"

Gem::Specification.new do |spec|
  spec.name          = "ph_no_to_word"
  spec.version       = PhNoToWord::VERSION
  spec.authors       = ["Abhilash A K"]
  spec.email         = ["abhilashamballur@gmail.com"]

  spec.summary       = %q{Converts the phone number into word characters}
  spec.description   = %q{This gem allows given 10 character phone number to convert into a word contained in a dictionary}
  spec.homepage      = "https://bitbucket.org/abhilashak/ph_no_to_word"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  #   spec.metadata["homepage_uri"] = spec.homepage
  #   spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #   spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.

  spec.files = %w[ph_no_to_word.gemspec] + Dir["*.md",
                                               "bin/*",
                                               "lib/**/*.rb",
                                               "lib/**/**/*.txt"
                                              ]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 2.5.3'
  spec.required_rubygems_version = ">= 2.7.6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
