module HydraAttribute
  module Model
    module HasManyThrough
      extend ActiveSupport::Concern

      class Relation
        def initialize(object, options = {})
          @object = object

          @relation_class     = options[:relation_class]
          @through_class      = options[:through_class]
          @through_method     = options[:through_method]
          @object_method_id   = options[:object_method_id]
          @relation_method_id = options[:relation_method_id]
          @copy_attribute     = options[:copy_attribute]
        end

        # API method
        # build relation object
        #
        # @param [Hash] attributes
        # @return [HydraAttribute::Model]
        def build(attributes = {})
          relation_object = @relation_class.new(prepare_relation_attributes(attributes))
          unsaved_relation_objects << relation_object
          relation_object
        end

        # API method
        # create relation object
        #
        # @param [Hash] attributes
        # @return [HydraAttribute::Model]
        def create(attributes = {})
          relation_object = @relation_class.create(prepare_relation_attributes(attributes))
          self << relation_object
          relation_object
        end

        # API method
        # add relation object
        #
        # @param [HydraAttribute::Model] relation_object
        # @return [HydraAttribute::Model::HasManyThrough::Relation]
        def <<(relation_object)
          if @object.persisted? && relation_object.persisted?
            @through_class.create(@object_method_id => @object.id, @relation_method_id => relation_object.id)
          else
            unsaved_relation_objects << relation_object
          end
          self
        end

        # API method
        # delete relation object
        #
        # @param [HydraAttribute::Model] relation_object
        # @return [HydraAttribute::Model::HasManyThrough::Relation]
        def destroy(relation_object)
          if @object.persisted? and relation_object.persisted?
            through_object = through_object_by_relation_object(relation_object)
            through_object.destroy if through_object
          else
            unsaved_relation_objects.delete(relation_object)
          end
          self
        end

        def save_unsaved_associations #:nodoc:
          unsaved_relation_objects.each do |relation_object|
            self << relation_object if relation_object.save
          end
          unsaved_relation_objects.clear
        end

        def delete_unsaved_associations #:nodoc:
          unsaved_relation_objects.clear
        end

        def inspect
          relation_objects.inspect
        end

        private
          def respond_to_missing?(method, include_private)
            relation_objects.respond_to?(method, include_private)
          end

          def method_missing(method, *args, &block)
            relation_objects.public_send(method, *args, &block)
          end

          def relation_objects
            persisted_relation_objects + unsaved_relation_objects
          end

          def persisted_relation_objects
            @through_class.send(@through_method, @object.id)
          end

          def unsaved_relation_objects
            @unsaved_relation_objects ||= []
          end

          def through_object_by_relation_object(relation_object)
            @through_class.all.find do |through_object|
              through_object.send(@object_method_id) == @object.id && through_object.send(@relation_method_id) == relation_object.id
            end
          end

          def prepare_relation_attributes(attributes)
            if @copy_attribute
              attributes.reverse_merge(@copy_attribute => @object.send(@copy_attribute))
            else
              attributes
            end
          end
      end

      module ClassMethods
        def has_many(collection, options = {})
          relation_class_name = "::HydraAttribute::#{collection.to_s.singularize.camelize}"       # HydraAttribute::HydraAttribute
          through_class_name  = "::HydraAttribute::#{options[:through].to_s.camelize}"            # HydraAttribute::HydraAttributeSet
          object_method_id    = "#{name.demodulize.underscore}_id"                                # 'hydra_set_id'
          relation_method_id  = "#{collection.to_s.singularize}_id"                               # 'hydra_attribute_id'
          through_method_name = "#{collection}_by_#{object_method_id}"                            # 'hydra_attributes_by_hydra_set_id'
          copy_attribute      = options[:copy_attribute] ? ":#{options[:copy_attribute]}" : 'nil' # :entity_type

          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{collection}
              @#{collection} ||= Relation.new(self,
                                              :relation_class     => #{relation_class_name},
                                              :through_class      => #{through_class_name},
                                              :through_method     => :#{through_method_name},
                                              :object_method_id   => :#{object_method_id},
                                              :relation_method_id => :#{relation_method_id},
                                              :copy_attribute     => #{copy_attribute})
            end

            def create
              result = super
              if result
                #{collection}.save_unsaved_associations
              end
              result
            end

            def update
              result = super
              if result
                #{collection}.save_unsaved_associations
              end
              result
            end

            def delete
              result = super
              if result
                #{collection}.delete_unsaved_associations
              end
              result
            end
          EOS
        end
      end
    end
  end
end