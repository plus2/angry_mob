require 'angry_hash'

class AngryHash
  def self.new_extended(mod,seed={})
    self[ seed ].tap {|hash| hash.extend(mod) }
  end

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

      def extend_hash(hash, mod, parent_hash)
        if !parent_hash.nil? && hash.nil?
          hash = AngryHash.new
        end

        hash.extend mod

        hash.__parent_hash = parent_hash if hash.respond_to?(:__parent_hash=)
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

          if options.key?(:default) && obj.nil?
            obj = options[:default]
          end

          case kind
          when :single
            obj = extend_hash(obj,mod,parent_obj)
          when :array
            # XXX - this is ok for now... we really need to typecheck, perhaps wrap in a smart-array
            obj ||= []
            obj = obj.map {|elt| extend_hash(elt, mod, parent_obj)}
          when :hash
            obj ||= {}
            obj = obj.inject(AngryHash.new) do |h,(k,elt)|
              h[k] = extend_hash(elt,mod,parent_obj)
              h
            end
          end
        end

        obj
      end
    end

    def [](key)
      Extension.mixin_to(self,key,super)
    end

    def id
      self['id']
    end

    def dup_with_extension
      dup.tap {|new_hash|
        new_hash.extend(__angry_hash_extension) if __angry_hash_extension
      }
    end

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

      def build(seed={})
        AngryHash[ seed ].tap {|hash|
          self.fill_in_defaults(hash)
          hash.extend self
        }
      end
    end
  end
end
