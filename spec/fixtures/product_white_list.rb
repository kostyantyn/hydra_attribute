HydraAttribute::Migrator.new(ActiveRecord::Base.connection).create :product_white_lists do |t|
  t.string :name
  t.string :title
  t.timestamps
end

class ProductWhiteList < ActiveRecord::Base
  include HydraAttribute::ActiveRecord

  attr_accessible :name

  self.mass_assignment_sanitizer = :logger
end