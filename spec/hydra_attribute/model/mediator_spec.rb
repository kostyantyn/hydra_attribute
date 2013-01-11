require 'spec_helper'

describe HydraAttribute::Model::Mediator do
  before do
    Object.const_set('M1', Class.new)
    Object.const_set('M2', Class.new)
    Object.const_set('M3', Class.new)

    M1.send(:include, HydraAttribute::Model::Mediator)
    M2.send(:include, HydraAttribute::Model::Mediator)
    M3.send(:include, HydraAttribute::Model::Mediator)

    M1.observe 'M2', create: :m2_created, destroy: :m2_destroyed
    M1.observe 'M3', create: :m3_created, destroy: :m3_destroyed
    M2.observe 'M3', create: :m3_created, destroy: :m3_destroyed
    M3.observe 'M1', create: :m1_created, destroy: :m1_destroyed

    def M1.logger=(logger) @logger = logger end
    def M2.logger=(logger) @logger = logger end
    def M3.logger=(logger) @logger = logger end

    def M1.m2_created(object) @logger << "M1:m2_created:#{object.__id__}" end
    def M1.m3_created(object) @logger << "M1:m3_created:#{object.__id__}" end
    def M2.m3_created(object) @logger << "M2:m3_created:#{object.__id__}" end
    def M3.m1_created(object) @logger << "M3:m1_created:#{object.__id__}" end

    def M1.m2_destroyed(object) @logger << "M1:m2_destroyed:#{object.__id__}" end
    def M1.m3_destroyed(object) @logger << "M1:m3_destroyed:#{object.__id__}" end
    def M2.m3_destroyed(object) @logger << "M2:m3_destroyed:#{object.__id__}" end
    def M3.m1_destroyed(object) @logger << "M3:m1_destroyed:#{object.__id__}" end
  end

  after do
    Object.send(:remove_const, 'M1')
    Object.send(:remove_const, 'M2')
    Object.send(:remove_const, 'M3')
  end

  it 'should notify subscribed listeners' do
    M1.logger = M2.logger = M3.logger = logger = []

    m1, m2, m3 = M1.new, M2.new, M3.new

    [:create, :destroy, :update].each do |event|
      m1.notify(event); m2.notify(event); m3.notify(event)
    end

    logger[0].should == "M3:m1_created:#{m1.__id__}"
    logger[1].should == "M1:m2_created:#{m2.__id__}"
    logger[2].should == "M1:m3_created:#{m3.__id__}"
    logger[3].should == "M2:m3_created:#{m3.__id__}"
    logger[4].should == "M3:m1_destroyed:#{m1.__id__}"
    logger[5].should == "M1:m2_destroyed:#{m2.__id__}"
    logger[6].should == "M1:m3_destroyed:#{m3.__id__}"
    logger[7].should == "M2:m3_destroyed:#{m3.__id__}"
    logger[8].should be_nil # no more listeners
  end
end