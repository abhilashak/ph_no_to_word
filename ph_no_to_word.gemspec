$:.push File.expand_path('../lib', __FILE__)
require 'ph_no_to_word/version'

Gem::Specification.new do |spec|
  spec.name          = 'ph_no_to_word'
  spec.version       = PhNoToWord::VERSION
  spec.authors       = ['Abhilash A K']
  spec.email         = ['abhilash.amballur@gmail.com']

  spec.summary       = 'Converts the phone number into word characters'
  spec.description   = 'This gem allows given 10 character phone number to convert into a word contained in a dictionary'
  spec.homepage      = 'https://github.com/abhilashak/ph_no_to_word'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = spec.homepage + '/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.required_ruby_version = '>= 2.5.3'
  spec.required_rubygems_version = '>= 2.7.6'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.require_paths = %w[lib]
  spec.files         = `git ls-files`.split("\n")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
end
