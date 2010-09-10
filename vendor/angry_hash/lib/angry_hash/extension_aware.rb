class AngryHash
  module ExtensionAware
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def [](seed)
        super.tap {|hash|
          copy_extension(seed,hash)
        }
      end

      def __convert(hash,cycle_watch=[])
        super.tap {|new_hash|
          copy_extension(hash,new_hash)
        }
      end

      def new_extended(mod,seed={})
        self[ seed ].tap {|hash| hash.extend(mod) }
      end

      def dup_with_extension(other)
        if AngryHash === other
          other.respond_to?(:dup_with_extension) ? other.dup_with_extension : other.dup
        elsif Hash === other
          dup_with_extension(AngryHash[other])
        elsif
          other.dup
        end
      end

      def copy_extension(from,to)
        to.tap {|t| t.extend(from.__angry_hash_extension) if from.respond_to?(:__angry_hash_extension)}
      end
    end

    def reverse_deep_merge(other_hash)
      super.tap {|merged|
        self.class.copy_extension(self,merged)
      }
    end
  end
end
