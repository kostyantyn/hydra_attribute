require 'spec_helper'

describe HydraAttribute::ActiveRecord::Scoping do
  describe '#scoped' do
    let(:ancestor) do
      method   = ::ActiveRecord::VERSION::STRING.starts_with?('3.1.') ? :to_a : :exec_queries
      instance = mock(:instance_relation, where: nil, method => nil)

      Module.new do
        define_method :scoped do |*|
          instance
        end
      end
    end

    let(:klass) { Class.new.extend(ancestor) }

    it 'should return ActiveRecord::Relation object with extended HydraAttribute::ActiveRecord::Relation module' do
      klass.send :include, HydraAttribute::ActiveRecord::Scoping
      klass.scoped.singleton_class.ancestors.should include(HydraAttribute::ActiveRecord::Relation)
    end
  end
end