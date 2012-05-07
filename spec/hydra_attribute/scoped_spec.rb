require 'spec_helper'

describe HydraAttribute::Scoped do
  describe '#scoped' do
    let(:klass) { Class.new.extend(Module.new{ def scoped(options) self end }) }

    it 'should return ActiveRecord::Relation object with extended HydraAttribute::ActiveRecord::Relation module' do
      klass.extend(HydraAttribute::Scoped)
      klass.scoped.singleton_class.ancestors.should include(HydraAttribute::ActiveRecord::Relation)
    end
  end
end