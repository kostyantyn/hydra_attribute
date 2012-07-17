module HydraAttribute
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer_file
        copy_file 'hydra_attribute.txt', 'config/initializers/hydra_attribute.rb'
      end
    end
  end
end