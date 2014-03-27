module HydraAttribute
  module Middleware
    class IdentityMap
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      ensure
        ::HydraAttribute.identity_map.clear
      end
    end
  end
end
