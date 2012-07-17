require 'spec_helper'

describe HydraAttribute::ActiveRecord do
  let(:klass) { Class.new.extend(HydraAttribute::ActiveRecord) }

  describe '#use_hydra_attributes' do
    it 'should build entity' do
      HydraAttribute::Builder.should_receive(:build).with(klass)
      klass.use_hydra_attributes
    end
  end
end