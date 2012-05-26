# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hydra_attribute/version', __FILE__)

Gem::Specification.new do |gem|
  gem.author                = 'Kostyantyn Stepanyuk'
  gem.email                 = 'kostya.stepanyuk@gmail.com'
  gem.summary               = 'hydra_attribute allows to use EAV database structure for ActiveRecord models.'
  gem.description           = 'hydra_attribute allows to use EAV database structure for ActiveRecord models.'
  gem.homepage              = ""
  gem.files                 = `git ls-files`.split("\n")
  gem.test_files            = `git ls-files -- Appraisals {spec,features,gemfiles}/*`.split("\n")
  gem.name                  = "hydra_attribute"
  gem.require_paths         = %w(lib)
  gem.required_ruby_version = Gem::Requirement.new('>= 1.9.2')
  gem.version               = HydraAttribute::VERSION

  gem.add_dependency('activerecord', '>= 3.1.0')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('cucumber')
  gem.add_development_dependency('sqlite3')
  gem.add_development_dependency('database_cleaner')
  gem.add_development_dependency('appraisal')
end