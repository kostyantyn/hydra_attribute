module HydraAttribute

  # ActiveRecord::Base extends this module.
  module ActiveRecord

    # Add EAV behavior to this model.
    # Generate attribute and value associations.
    def use_hydra_attributes
      Builder.build(self)
    end

    # Create reflection for hydra association
    def create_reflection(macro, name, options, active_record)
      if name.to_s.start_with?('hydra_')
        reflections[name] = Reflection.new(macro, name, options, active_record)
      else
        super
      end
    end
  end
end