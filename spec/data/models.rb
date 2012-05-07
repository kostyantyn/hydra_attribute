class Product < ActiveRecord::Base
end

class SimpleProduct < Product
  hydra_attributes do |hydra|
    hydra.string  :name, :code
    hydra.float   :price
    hydra.boolean :active
    hydra.text    :description
  end
end

class GroupProduct < Product
  hydra_attributes do |hydra|
    hydra.string  :name, :title
    hydra.float   :price
    hydra.boolean :active
    hydra.integer :total
  end
end