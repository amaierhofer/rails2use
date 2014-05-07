# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails2use/version'

Gem::Specification.new do |spec|
  spec.name          = "rails2use"
  spec.version       = Rails2use::VERSION
  spec.authors       = ["Manuel Dudda"]
  spec.email         = ["dudda@redpeppix.de"]
  spec.summary       = "Extracts all rails model to one UML file written in USE (UML-based Specification Environment)."
  spec.description   = "Currently is only ActiveRecord supported. Wrappers for Mongoid and others are planned."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'rails'
end
