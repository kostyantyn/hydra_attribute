require 'hydra_attribute'

ActiveSupport.on_load(:active_record) do
  self.default_timezone          = :utc
  self.mass_assignment_sanitizer = :strict
end

ENV['DB'] ||= 'sqlite'
require File.expand_path("../environments/#{ENV['DB']}", __FILE__)

if ENV['SQL_LOGGER']
  require 'active_support/all'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

Dir[File.expand_path('../fixtures/*.rb', __FILE__)].each do |file|
  load file
end

RSpec.configure do |config|
  config.before do
    Thread.current[:hydra_attribute] = nil
  end
end