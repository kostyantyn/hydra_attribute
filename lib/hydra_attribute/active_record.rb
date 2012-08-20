module HydraAttribute
  module ActiveRecord
    def self.append_features(base)
      unless base.ancestors.include?(::ActiveRecord::Base)
        raise %(Cannot include HydraAttribute::ActiveRecord module because "#{base}" is not inherited from ActiveRecord::Base)
      end

      unless base.base_class.equal?(base)
        raise %(HydraAttribute::ActiveRecord module should be included to base class "#{base.base_class}" instead of "#{base}")
      end

      super

      base.extend(ClassMethods)
      Builder.build(base)
    end

    module ClassMethods
      def create_reflection(macro, name, options, active_record)
        if name.to_s.start_with?('hydra_')
          reflections[name] = Reflection.new(macro, name, options, active_record)
        else
          super
        end
      end
    end

  end
end