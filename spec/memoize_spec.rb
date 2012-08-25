require 'spec_helper'

describe HydraAttribute::Memoize do
  describe '#memorize' do
    it 'should cache method result' do
      anonymous = Class.new do
        extend HydraAttribute::Memoize

        def my_method
          result
        end
        hydra_memoize :my_method
      end

      instance = anonymous.new
      instance.should_receive(:result).once.and_return([1,2,3])
      2.times { instance.my_method.should == [1,2,3] }
    end

    it 'should cache method result with one parameter' do
      anonymous = Class.new do
        extend HydraAttribute::Memoize

        def my_method(a)
          result(a)
        end
        hydra_memoize :my_method
      end

      instance = anonymous.new
      instance.should_receive(:result).with(1).once.and_return([1,1,1])
      instance.should_receive(:result).with(2).once.and_return([2,2,2])

      2.times { instance.my_method(1).should == [1,1,1] }
      2.times { instance.my_method(2).should == [2,2,2] }
    end

    it 'should cache method result with two parameters' do
      anonymous = Class.new do
        extend HydraAttribute::Memoize

        def my_method(a, b)
          result(a, b)
        end
        hydra_memoize :my_method
      end

      instance = anonymous.new
      instance.should_receive(:result).with(1, 1).once.and_return([1,1,1])
      instance.should_receive(:result).with(1, 2).once.and_return([1,1,2])
      instance.should_receive(:result).with(2, 1).once.and_return([2,2,1])

      2.times { instance.my_method(1, 1).should == [1,1,1] }
      2.times { instance.my_method(1, 2).should == [1,1,2] }
      2.times { instance.my_method(2, 1).should == [2,2,1] }
    end
  end
end