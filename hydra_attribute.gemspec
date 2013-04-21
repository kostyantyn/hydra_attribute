# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hydra_attribute/version', __FILE__)

Gem::Specification.new do |gem|
  gem.author                = 'Kostyantyn Stepanyuk'
  gem.email                 = 'kostya.stepanyuk@gmail.com'
  gem.summary               = 'hydra_attribute is an implementation of EAV pattern for ActiveRecord models.'
  gem.description           = 'hydra_attribute is an implementation of EAV pattern for ActiveRecord models.'
  gem.homepage              = 'https://github.com/kostyantyn/hydra_attribute'
  gem.files                 = `git ls-files`.split("\n")
  gem.test_files            = `git ls-files -- {spec,features,gemfiles}/*`.split("\n")
  gem.name                  = 'hydra_attribute'
  gem.require_paths         = %w(lib)
  gem.required_ruby_version = Gem::Requirement.new('>= 1.9.2')
  gem.version               = HydraAttribute::VERSION

  gem.add_dependency('activerecord', '~> 3.2')

  gem.add_development_dependency('rspec', '~> 2.13')
  gem.add_development_dependency('sqlite3')
  gem.add_development_dependency('mysql2')
  gem.add_development_dependency('pg')
  gem.add_development_dependency('rake')
end
