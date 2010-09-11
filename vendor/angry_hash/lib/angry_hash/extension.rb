class AngryHash
  module Extension
    class << self
      def included(base)
        base.extend ClassMethods

        base.module_eval do
          def self.extend_object(obj)
            super
            Extension.mark_extension(obj,self)
          end
        end
      end

      def mark_extension(hash,mod)
        #puts "mark_extension hash=#{hash.class} mod=#{mod}"
        
        if (previous_mod = hash.__angry_hash_extension) && previous_mod != mod
          raise "hash #{hash} has already been extended by a different AngryHash::Extension (was: #{previous_mod}, now: #{mod})"
        end
        hash.__angry_hash_extension = mod

        setup_extended_hash(hash,mod)
      end

      # A record of extensions to fields of classes.
      def mixin_registry
        @mixin_registry ||= Hash.new {|h,k| h[k] = {}}
      end

      # Register a value extension
      def register_mixin(target_class,field,mod,options)
        mixin_registry[target_class][field.to_s] = [:single, mod, options]
      end

      # Register an array extension
      def register_mixin_array(target_class, field, mod, options)
        mixin_registry[target_class][field.to_s] = [:array, mod, options]
      end

      # Register a hash extension
      def register_mixin_hash(target_class, field, mod, options)
        mixin_registry[target_class][field.to_s] = [:hash, mod, options]
      end

      # Register a block extension - applied to objects of the defining module.
      # This is in contrast to the other mixin types which are applied to subordinate objects.
      def register_mixin_block(target_class, options)
        mixin_registry[target_class]['*'] = [:block, options]
      end

      def extend_hash(hash, mod, parent_hash, block)
        if !parent_hash.nil? && hash.nil?
          hash = AngryHash.new
        end

        hash.extend mod

        hash.__parent_hash = parent_hash if hash.respond_to?(:__parent_hash=)

        if block
          hash.instance_eval(&block)
        end

        hash
      end

      def setup_extended_hash(hash, mod)
        mod.fill_in_defaults(hash) if mod.respond_to?(:fill_in_defaults)
        hash
      end

      def mixin_to(parent_obj, field, obj)
        extension = parent_obj.__angry_hash_extension

        if mixin = mixin_registry[extension][field.to_s]
          kind,mod,options = *mixin

          if options[:allow_nil] && obj.nil?
            return nil
          end

          if options.key?(:default) && obj.nil?
            obj = options[:default]
          end



          # the result of `extend_self` block
          extend_self = if (sub_ext = mixin_registry[mod]['*']) && sub_ext[0] == :block
                          sub_ext[1][:block]
                        end

          case kind
          when :single
            obj = extend_hash(obj,mod,parent_obj,extend_self)
          when :array
            # XXX - this is ok for now... we really need to typecheck, perhaps wrap in a smart-array
            obj ||= []
            obj = obj.map! {|elt| extend_hash(elt, mod, parent_obj, extend_self) }
          when :hash
            obj ||= {}
            obj.replace( obj.inject(AngryHash.new) {|h,(k,elt)|
              h[k] = extend_hash(elt,mod,parent_obj, extend_self)
              h
            })
          end
          
          
        end

        obj
      end
    end # Extension module methods

    ## Instance methods

    def [](key)
      Extension.mixin_to(self,key,super)
    end

    def id
      self['id']
    end

    def dup_with_extension
      dup.tap {|new_hash|
        AngryHash.copy_extension(self,new_hash)
      }
    end

    ## AngryHash extension attributes
    # These should be copied using `AngryHash.copy_extension` when duping
    def __parent_hash=(hash)
      @__parent_hash = hash
    end

    def __parent_hash
      @__parent_hash
    end

    def __angry_hash_extension=(mod)
      @__angry_hash_extension = mod
    end

    def __angry_hash_extension
      @__angry_hash_extension
    end


    module ClassMethods
      def defaults(default_form=nil)
        if default_form
          @default_form = default_form
        end
        @default_form
      end

      def fill_in_defaults(hash)
        if defaults
          hash.reverse_deep_update(defaults)
        end
      end

      def extend_value(field,mod,options={})
        Extension.register_mixin(self,field,mod,options)
      end

      def extend_array(field,mod,options={})
        Extension.register_mixin_array(self,field,mod,options)
      end

      def extend_hash(field,mod,options={})
        Extension.register_mixin_hash(self,field,mod,options)
      end

      def extend_self(options={}, &block)
        options[:block] = block
        Extension.register_mixin_block(self,options)
      end

      def build(seed={})
        AngryHash[ seed ].tap {|hash|
          self.fill_in_defaults(hash)
          hash.extend self
        }
      end
    end
  end
end
