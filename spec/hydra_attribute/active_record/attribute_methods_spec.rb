require 'spec_helper'

describe HydraAttribute::ActiveRecord::AttributeMethods do
  describe '#column_for_attribute' do
    let!(:hydra_attribute) { Product.hydra_attributes.create(name: 'code',  backend_type: 'string',  default_value: 'abc') }
    let(:product)          { Product.new }

    it 'should return column for hydra attribute' do
      column = product.column_for_attribute(:code)
      column.should be_kind_of(ActiveRecord::ConnectionAdapters::Column)
      column.name.should == 'code'
    end

    it 'should return column for static attribute' do
      column = product.column_for_attribute(:name)
      column.should be_kind_of(ActiveRecord::ConnectionAdapters::Column)
      column.name.should == 'name'
    end

    it 'should return nil if cannot find attribute' do
      product.column_for_attribute(:fake).should be_nil
    end
  end
end
