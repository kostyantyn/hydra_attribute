require 'spec_helper'

describe HydraAttribute::Builder do
  let(:klass) { Class.new }

  describe '.build' do
    it 'should include hydra modules' do
      HydraAttribute::Builder.any_instance.stub(build: nil)
      HydraAttribute::Builder.build(klass)
      klass.should include(HydraAttribute::ActiveRecord::Scoping)
      klass.should include(HydraAttribute::ActiveRecord::AttributeMethods)
    end

    it 'should run AssociationBuilder for each support type' do
      HydraAttribute::SUPPORT_TYPES.each do |type|
        HydraAttribute::AssociationBuilder.should_receive(:build).with(klass, type)
      end
      HydraAttribute::Builder.build(klass)
    end
  end
end