module HydraAttribute
  module AttributeProxy
    def use_proxy_to_hydra_attribute(symbol)
      module_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{symbol}(attr_name)
          if self.class.hydra_attribute_names.include?(attr_name.to_sym)
            type = self.class.hydra_attributes[attr_name.to_sym]
            hydra_attribute_model(attr_name.to_sym, type).#{symbol}('value')
          else
            super
          end
        end
      EOS
    end
  end
end