require 'spec_helper'

describe HydraAttribute::ActiveRecord::Scoping do
  describe '#scoped' do
    let(:ancestor) do
      Module.new do
        def scoped(*) self end
        def where(*) self end
      end
    end

    let(:klass) { Class.new.extend(ancestor) }

    it 'should return ActiveRecord::Relation object with extended HydraAttribute::ActiveRecord::Relation module' do
      klass.send :include, HydraAttribute::ActiveRecord::Scoping
      klass.scoped.singleton_class.ancestors.should include(HydraAttribute::ActiveRecord::Relation)
    end
  end
end