# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scallop/version'

Gem::Specification.new do |spec|
  spec.name          = 'scallop'
  spec.version       = Scallop::VERSION
  spec.authors       = ['FetLife']
  spec.email         = ['dev@fetlife.com']

  spec.summary       = 'Ergonomic shell wrapper.'
  spec.description   = 'Ergonomic shell wrapper.'
  spec.homepage      = 'https://github.com/fetlife/scallop'
  spec.license       = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features|.circleci)/}) || f.end_with?('.png')
    end
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4'
  spec.add_development_dependency 'rubocop', '~> 0.71'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
