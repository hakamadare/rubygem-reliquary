# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reliquary/version'

Gem::Specification.new do |spec|
  spec.name          = "reliquary"
  spec.version       = Reliquary::VERSION
  spec.authors       = ["Steve Huff"]
  spec.email         = ["shuff@vecna.org"]

  spec.summary       = %q{Client for New Relic API v2.}
  spec.description   = %q{The official New Relic Ruby gem only supports API v1.}
  spec.homepage      = "https://github.com/hakamadare/rubygem-reliquary"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "chronic", "~> 0.10"
  spec.add_dependency "multi_json", "~> 1.11"
  spec.add_dependency "oj", "~> 3.3"
  spec.add_dependency "rest-client", "~> 2.0"

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bond", "~> 0.5"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "dotenv", "~> 2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard", "~> 0.8"
end
