module HydraAttribute
  module Memoize
    def hydra_memoize(*methods)
      methods.each do |method_name|
        bound_method = instance_method(method_name)
        alias_method "unmemoized_#{method_name}", method_name

        if bound_method.arity.abs == 0
          module_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{method_name}
              @#{method_name} = unmemoized_#{method_name} unless instance_variable_defined?(:@#{method_name})
              @#{method_name}
            end
          EOS
        else
          args = 1.upto(bound_method.arity.abs).map { |i| "a#{i}" }
          keys = 1.upto(bound_method.arity.abs).map { |i| "k#{i}" }

          call = args.inject("@#{method_name}") do |hash_call, arg|
            "#{hash_call}[#{arg}]"
          end

          hash = keys.reverse.inject("unmemoized_#{method_name}(#{keys.join(', ')})") do |code, key|
            "Hash.new { |hash, #{key}| hash[#{key}] = #{code} }"
          end

          module_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{method_name}(#{args.join(', ')})      # def method(a1)
              @#{method_name} ||= #{hash}               #   @method ||= Hash.new { |hash, key1| hash[key1] = unmemoized_method(key1) }
              #{call}                                   #   @method[a1]
            end                                         # end
          EOS
        end
      end
    end
  end
end