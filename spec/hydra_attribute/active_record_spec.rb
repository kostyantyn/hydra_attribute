require 'spec_helper'

describe HydraAttribute::ActiveRecord do
  let(:klass) { Class.new.extend(HydraAttribute::ActiveRecord) }

  describe '#define_hydra_attributes' do
    it 'should yield block with preconfigured current class' do
      builder = nil
      klass.define_hydra_attributes { |b| builder = b }
      builder.should be_an_instance_of(HydraAttribute::Builder)
      builder.klass.should be_equal(klass)
      klass.should be_a_kind_of(HydraAttribute::ActiveRecord::Scoping)
    end
  end
end