HydraAttribute::Migrator.new(ActiveRecord::Base.connection).create :rooms do |t|
  t.integer :flat_id
  t.integer :square
  t.timestamps
end

class Room < ActiveRecord::Base
  include HydraAttribute::ActiveRecord

  belongs_to :flat
end
