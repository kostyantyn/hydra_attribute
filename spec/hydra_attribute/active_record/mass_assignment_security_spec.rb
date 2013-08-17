require 'spec_helper'

module HydraAttribute::ActiveRecord::MassAssignmentSecurity
  describe 'WhiteList' do
    before do
      ProductWhiteList.hydra_attributes.create(name: 'color', backend_type: 'string', white_list: true)
      ProductWhiteList.hydra_attributes.create(name: 'code',  backend_type: 'string', white_list: false)
    end

    let(:product) { ProductWhiteList.new(name: 'name', title: 'title', color: 'green', code: 'abc') }

    it 'should assign only hydra attributes which are in white list' do
      product.color.should == 'green'
      product.code.should be_nil
    end

    it 'should not break default behavior for static attributes' do
      product.name.should == 'name'
      product.title.should be_nil
    end
  end

  describe 'BlackList' do
    before do
      ProductBlackList.hydra_attributes.create(name: 'color', backend_type: 'string', white_list: true)
      ProductBlackList.hydra_attributes.create(name: 'code',  backend_type: 'string', white_list: false)
    end

    let(:product) { ProductBlackList.new(name: 'name', title: 'title', color: 'green', code: 'abc') }

    it 'should assign only hydra attributes which are in white list' do
      product.color.should == 'green'
      product.code.should be_nil
    end

    it 'should not break default behavior for static attributes' do
      product.name.should be_nil
      product.title.should == 'title'
    end
  end
end