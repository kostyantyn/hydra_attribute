module HydraAttribute
  class Railtie < Rails::Railtie
    initializer 'hydra_attribute.active_record' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Migration.send(:include, ::HydraAttribute::ActiveRecord::Migration)
      end
    end

    initializer 'hydra_attribute.middleware' do |app|
      require 'hydra_attribute/middleware/identity_map'
      app.middleware.use ::HydraAttribute::Middleware::IdentityMap
    end
  end
end