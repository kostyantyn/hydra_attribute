# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hydra_attribute/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kostyantyn Stepanyuk"]
  gem.email         = ["kostya.stepanyuk@gmail.com"]
  gem.description   = "This gem extends ActiveRecord to use EAV structure data."
  gem.summary       = "This gem extends ActiveRecord to use EAV structure data."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hydra_attribute"
  gem.require_paths = ["lib"]
  gem.version       = HydraAttribute::VERSION

  gem.add_dependency('activerecord', '~> 3.1')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('sqlite3')
  gem.add_development_dependency('database_cleaner')
  gem.add_development_dependency('appraisal')
end