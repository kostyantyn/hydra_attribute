require 'spec_helper'

describe HydraAttribute::ActiveRecord do
  let(:klass) { Class.new.extend(HydraAttribute::ActiveRecord) }

  describe '#define_hydra_attributes' do
    let(:builder) { @builder }
    before        { klass.define_hydra_attributes { |b| @builder = b } }

    it 'should yield block with preconfigured current class' do
      builder.should be_an_instance_of(HydraAttribute::Builder)
      builder.klass.should be_equal(klass)

    end

    it 'should include HydraAttribute::ActiveRecord::Scoping to class' do
      klass.should include(HydraAttribute::ActiveRecord::Scoping)
    end
  end
end