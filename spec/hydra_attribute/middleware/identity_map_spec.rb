require 'spec_helper'
require 'hydra_attribute/middleware/identity_map'

describe HydraAttribute::Middleware::IdentityMap do
  describe '#call' do
    let(:app) do
      lambda do |*|
        ::HydraAttribute.identity_map[:key2] = :value2
        expect(::HydraAttribute.identity_map).to eq(key: :value, key2: :value2)
      end
    end

    before { ::HydraAttribute.identity_map[:key] = :value }

    it 'should clear identity map after request' do
      expect(app).to receive(:call).and_call_original
      HydraAttribute::Middleware::IdentityMap.new(app).call(nil)
      expect(::HydraAttribute.identity_map).to eq({})
    end
  end
end
