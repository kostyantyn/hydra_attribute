require 'spec_helper'

describe HydraAttribute::Memoize do
  def anonymous(arity = 0)
    params = (1..arity).map{ |i| "a#{i}" }.join(', ')

    anonymous = Class.new do
      extend HydraAttribute::Memoize

      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def my_method(#{params})
          result(#{params})
        end
        hydra_memoize :my_method
      EOS
    end
    anonymous.new
  end

  describe '#memoize' do
    it 'method without parameters' do
      instance = anonymous
      instance.should_receive(:result).once.and_return([1,2,3])
      2.times { instance.my_method.should == [1,2,3] }
    end

    it 'method without parameters which returns nil' do
      instance = anonymous
      instance.should_receive(:result).once.and_return(nil)
      2.times { instance.my_method.should == nil }
    end

    it 'method with one parameter' do
      instance = anonymous(1)
      instance.should_receive(:result).with(1).once.and_return([1,1,1])
      instance.should_receive(:result).with(2).once.and_return([2,2,2])

      2.times { instance.my_method(1).should == [1,1,1] }
      2.times { instance.my_method(2).should == [2,2,2] }
    end

    it 'method with one parameter which returns nil' do
      instance = anonymous(1)
      instance.should_receive(:result).with(1).once.and_return(nil)
      instance.should_receive(:result).with(2).once.and_return(nil)

      2.times { instance.my_method(1).should == nil }
      2.times { instance.my_method(2).should == nil }
    end

    it 'method with two parameters' do
      instance = anonymous(2)
      instance.should_receive(:result).with(1, 1).once.and_return([1,1,1])
      instance.should_receive(:result).with(1, 2).once.and_return([1,1,2])
      instance.should_receive(:result).with(2, 1).once.and_return([2,2,1])

      2.times { instance.my_method(1, 1).should == [1,1,1] }
      2.times { instance.my_method(1, 2).should == [1,1,2] }
      2.times { instance.my_method(2, 1).should == [2,2,1] }
    end

    it 'method with two parameters' do
      instance = anonymous(2)
      instance.should_receive(:result).with(1, 1).once.and_return(nil)
      instance.should_receive(:result).with(1, 2).once.and_return(nil)
      instance.should_receive(:result).with(2, 1).once.and_return(nil)

      2.times { instance.my_method(1, 1).should == nil }
      2.times { instance.my_method(1, 2).should == nil }
      2.times { instance.my_method(2, 1).should == nil }
    end

    it 'method with three parameters' do
      instance = anonymous(3)
      instance.should_receive(:result).with(1, 1, 2).once.and_return([1,1,2])
      instance.should_receive(:result).with(1, 2, 2).once.and_return([1,2,2])
      instance.should_receive(:result).with(2, 2, 1).once.and_return([2,2,1])

      2.times { instance.my_method(1, 1, 2).should == [1,1,2] }
      2.times { instance.my_method(1, 2, 2).should == [1,2,2] }
      2.times { instance.my_method(2, 2, 1).should == [2,2,1] }
    end

    it 'method with three parameters' do
      instance = anonymous(3)
      instance.should_receive(:result).with(1, 1, 2).once.and_return(nil)
      instance.should_receive(:result).with(1, 2, 2).once.and_return(nil)
      instance.should_receive(:result).with(2, 2, 1).once.and_return(nil)

      2.times { instance.my_method(1, 1, 2).should == nil }
      2.times { instance.my_method(1, 2, 2).should == nil }
      2.times { instance.my_method(2, 2, 1).should == nil }
    end
  end
end