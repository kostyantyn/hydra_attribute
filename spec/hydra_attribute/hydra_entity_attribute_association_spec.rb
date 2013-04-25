require 'spec_helper'

describe HydraAttribute::HydraEntityAttributeAssociation do
  describe '#has_proxy_method?' do
    let(:association)      { HydraAttribute::HydraEntityAttributeAssociation.new(Product.new) }
    let!(:hydra_attribute) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'string') }

    it 'should return true if hydra_attribute has appropriate attribute for entity type' do
      [:code, :code=, :code_was, :code_before_type_cast].each do |method|
        association.should have_proxy_method(method)
      end
    end

    it 'should return false if hydra_attribute has not appropriate attribute for entity type' do
      HydraAttribute::HydraAttribute.create(entity_type: 'Category', name: 'title', backend_type: 'string')
      [:title, :title=, :title_was, :title_before_type_cast].each do |method|
        association.should_not have_proxy_method(method)
      end
    end

    it 'should correct resolve if new attribute was created in runtime' do
      [:title, :title=, :title_was, :title_before_type_cast].each do |method|
        association.should_not have_proxy_method(method)
      end

      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string')

      [:title, :title=, :title_was, :title_before_type_cast].each do |method|
        association.should have_proxy_method(method)
      end
    end

    it 'should correct resolve if attribute name was updated' do
      [:code, :code=, :code_was, :code_before_type_cast].each do |method|
        association.should have_proxy_method(method)
      end

      hydra_attribute.name = 'title'
      hydra_attribute.save

      [:code, :code=, :code_was, :code_before_type_cast].each do |method|
        association.should_not have_proxy_method(method)
      end

      [:title, :title=, :title_was, :title_before_type_cast].each do |method|
        association.should have_proxy_method(method)
      end
    end

    it 'should correct resolve if attribute entity type was updated' do
      hydra_attribute.entity_type = 'Category'
      hydra_attribute.save

      category_assoc = HydraAttribute::HydraEntityAttributeAssociation.new(Category.new)
      [:code, :code=, :code_was, :code_before_type_cast].each do |method|
        association.should_not have_proxy_method(method)
        category_assoc.should have_proxy_method(method)
      end
    end

    it 'should correct resolve if hydra attribute was deleted' do
      hydra_attribute.destroy
      [:code, :code=, :code_was, :code_before_type_cast].each do |method|
        association.should_not have_proxy_method(method)
      end
    end
  end

  describe '#delegate' do
    let!(:hydra_attribute1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'color', backend_type: 'string', default_value: 'green') }
    let!(:hydra_attribute2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string') }
    let(:association)       { HydraAttribute::HydraEntityAttributeAssociation.new(Product.new) }

    it 'should correct proxy method to hydra value' do
      association.delegate(:color).should == 'green'
      association.delegate(:title).should be_nil

      association.delegate(:color?).should be_true
      association.delegate(:title?).should be_false

      association.delegate(:color=, 'black')
      association.delegate(:title=, 'qwerty')

      association.delegate(:color).should == 'black'
      association.delegate(:title).should == 'qwerty'

      association.delegate(:color?).should be_true
      association.delegate(:title?).should be_true
    end

    it 'should raise an error if attribute name is unknown' do
      lambda do
        association.delegate(:price)
      end.should raise_error(HydraAttribute::HydraEntityAttributeAssociation::WrongProxyMethodError, 'Unknown :price method')
    end

    it 'should raise an error if hydra set does not have attribute' do
      hydra_set = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default')
      association.entity.hydra_set_id = hydra_set.id

      lambda do
        association.delegate(:color)
      end.should raise_error(HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{hydra_attribute1.id} is missed in Set ID #{hydra_set.id}")
    end

    it 'should delegate to method if it was created in runtime' do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'one', backend_type: 'string', default_value: 'one')
      association.delegate(:one).should == 'one'
    end

    it 'should delegate to method if attribute name was updated in runtime' do
      hydra_attribute1.name = 'color1'
      hydra_attribute1.save

      lambda { association.delegate(:color)  }.should raise_error(HydraAttribute::HydraEntityAttributeAssociation::WrongProxyMethodError)
      lambda { association.delegate(:color1) }.should_not raise_error
    end

    it 'should delegate to method if attribute entity type was updated in runtime' do
      hydra_attribute1.entity_type = 'Category'
      hydra_attribute1.save

      lambda { association.delegate(:color) }.should raise_error(HydraAttribute::HydraEntityAttributeAssociation::WrongProxyMethodError)
      lambda { HydraAttribute::HydraEntityAttributeAssociation.new(Category.new) }.should_not raise_error
    end

    it 'should not delegate to method if attribute was deleted in runtime' do
      hydra_attribute1.destroy
      lambda { association.delegate(:color) }.should raise_error(HydraAttribute::HydraEntityAttributeAssociation::WrongProxyMethodError)
    end
  end
end