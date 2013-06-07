module HydraAttribute
  module Model
    module Mediator
      extend ActiveSupport::Concern

      class << self
        # Holds all subscriptions
        #
        # @return [Hash]
        def subscriptions
          @subscriptions ||= Hash.new do |reporters, reporter|
            reporters[reporter] = Hash.new do |events, event|
              events[event] = []
            end
          end
        end

        # Subscribes listeners for reporter event
        #
        # @param [String] listener the name of the class which listens the event
        # @param [String] reporter
        # @param [Hash] events
        # @return [NilClass]
        def subscribe(listener, reporter, events)
          events.each do |event, callback|
            subscriptions[reporter][event] << [listener, callback]
          end
        end

        # Notifies listeners
        #
        # @param [String] reporter
        # @param [Symbol] event
        # @param [HydraAttribute::Model::Mediator] object
        # @return [NilClass]
        def notify(reporter, event, object)
          subscriptions[reporter][event].each do |listener, callback|
            listener.constantize.send(callback, object)
          end
        end

        # Clears all subscriptions
        #
        # @return [NilClass]
        def clear
          @subscriptions = nil
        end
      end

      module ClassMethods
        # Defines which class and its methods this object should observe
        #
        # @example
        #   class ModelOne
        #     include HydraAttribute::Model::Mediator
        #     observe 'ModelTwo', create: :model_two_created, destroy: :model_two_destroyed
        #
        #     def self.model_two_created(model_two)
        #     end
        #
        #     def self.model_two_destroyed(model_two)
        #     end
        #   end
        #
        # @param [String] class_name
        # @param [Hash] events
        # @return [NilClass]
        def observe(class_name, events)
          Mediator.subscribe(name, class_name, events)
        end
      end

      # Notifies all listeners about event
      #
      # @param [Symbol] event
      # @return [NilClass]
      def notify(event)
        if block_given?
          Mediator.notify(self.class.name, "before_#{event}".to_sym, self)
          result = yield
          Mediator.notify(self.class.name, "after_#{event}".to_sym, self)
          result
        else
          Mediator.notify(self.class.name, event, self)
        end
      end
    end
  end
end