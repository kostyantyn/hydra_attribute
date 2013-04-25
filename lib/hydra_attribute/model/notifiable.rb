module HydraAttribute
  module Model
    module Notifiable
      extend ActiveSupport::Concern

      private
        # Overwrite for notifying subscribed objects
        def create
          notify(:create) { super }
        end

        # Overwrite for notifying subscribed objects
        def update
          notify(:update) { super }
        end

        # Overwrite for notifying subscribed objects
        def delete
          notify(:destroy) { super }
        end
    end
  end
end