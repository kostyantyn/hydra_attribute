HydraAttribute::Migrator.new(ActiveRecord::Base.connection).create :product_black_lists do |t|
  t.string :name
  t.string :title
  t.timestamps
end

class ProductBlackList < ActiveRecord::Base
  include HydraAttribute::ActiveRecord

  attr_protected :name

  self.mass_assignment_sanitizer = :logger
end