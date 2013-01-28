require 'hydra_attribute'

ActiveSupport.on_load(:active_record) do
  self.default_timezone          = :utc
  self.mass_assignment_sanitizer = :strict
end

db = ENV['DB'] || 'sqlite3'
require File.expand_path("../environments/#{db}", __FILE__)

Dir[File.expand_path('../fixtures/*.rb', __FILE__)].each do |file|
  load file
end

RSpec.configure do |config|
  config.before do
    Thread.current[:hydra_attribute] = nil
  end
end