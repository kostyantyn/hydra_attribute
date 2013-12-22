require 'spec_helper'

module HydraAttribute::ActiveRecord::MassAssignmentSecurity
  describe 'WhiteList' do
    before do
      ProductWhiteList.hydra_attributes.create(name: 'color', backend_type: 'string',   white_list: true)
      ProductWhiteList.hydra_attributes.create(name: 'code',  backend_type: 'string',   white_list: false)
      ProductWhiteList.hydra_attributes.create(name: 'seen',  backend_type: 'datetime', white_list: true)
    end

    let(:product) do
      ProductWhiteList.new(
        :name      => 'name',
        :title     => 'title',
        :color     => 'green',
        :code      => 'abc',
        'seen(1i)' => '2012',
        'seen(2i)' => '12',
        'seen(3i)' => '22',
        'seen(4i)' => '15',
        'seen(5i)' => '30'
      )
    end

    it 'should assign only hydra attributes which are in white list' do
      product.color.should == 'green'
      product.seen.should  == DateTime.new(2012, 12, 22, 15, 30)
      product.code.should be_nil
    end

    it 'should not break default behavior for static attributes' do
      product.name.should == 'name'
      product.title.should be_nil
    end
  end

  describe 'BlackList' do
    before do
      ProductBlackList.hydra_attributes.create(name: 'color', backend_type: 'string',   white_list: true)
      ProductBlackList.hydra_attributes.create(name: 'code',  backend_type: 'string',   white_list: false)
      ProductBlackList.hydra_attributes.create(name: 'seen',  backend_type: 'datetime', white_list: true)
    end

    let(:product) do
      ProductBlackList.new(
        :name      => 'name',
        :title     => 'title',
        :color     => 'green',
        :code      => 'abc',
        'seen(1i)' => '2012',
        'seen(2i)' => '12',
        'seen(3i)' => '22',
        'seen(4i)' => '15',
        'seen(5i)' => '30'
      )
    end

    it 'should assign only hydra attributes which are in white list' do
      product.color.should == 'green'
      product.seen.should  == DateTime.new(2012, 12, 22, 15, 30)
      product.code.should be_nil
    end

    it 'should not break default behavior for static attributes' do
      product.name.should be_nil
      product.title.should == 'title'
    end
  end
end