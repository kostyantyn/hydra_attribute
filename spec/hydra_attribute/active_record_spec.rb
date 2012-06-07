require 'spec_helper'

describe HydraAttribute::ActiveRecord do
  let(:klass) { Class.new.extend(HydraAttribute::ActiveRecord) }

  describe '#define_hydra_attributes' do
    it 'should yield block in builder scope' do
      klass.define_hydra_attributes do
        self.class.should == HydraAttribute::Builder
      end
    end

    it 'should include HydraAttribute::ActiveRecord::Scoping to class' do
      klass.define_hydra_attributes {}
      klass.should include(HydraAttribute::ActiveRecord::Scoping)
    end
  end
end