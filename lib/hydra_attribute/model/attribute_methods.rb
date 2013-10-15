module HydraAttribute
  module Model
    module AttributeMethods
      extend ActiveSupport::Concern

      # Used by for form_for helper
      def to_key
        [id] if id
      end
    end
  end
end