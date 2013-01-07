module HydraAttribute
  class IdentityMap < Hash

    # Get value if key exists otherwise set a value
    # Block has a higher priority then value parameter
    #
    # @param [String, Symbol] key
    # @param [Object] value
    # @yield
    # @return [Object]
    def cache(key, value = nil)
      fetch(key) do
        self[key] = block_given? ? yield : value
      end
    end
  end
end