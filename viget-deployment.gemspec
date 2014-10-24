# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'viget/deployment/version'

Gem::Specification.new do |gem|
  gem.name          = "viget-deployment"
  gem.version       = Viget::Deployment::VERSION
  gem.authors       = ["Viget Developers"]
  gem.email         = ["developers@viget.com"]
  gem.description   = %q{Viget-specific deployment recipes}
  gem.summary       = gem.description
  gem.homepage      = "http://viget.com/extend"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'capistrano', '~> 2.15.0'
  gem.add_dependency 'tinder',     '~> 1.10.0'
  gem.add_dependency 'whenever',   '~> 0.8.0'
end
