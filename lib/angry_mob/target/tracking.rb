class AngryMob
  class Target
    module Tracking
      class << self
        def included(base) #:nodoc:
          base.send :extend,  ClassMethods
        end

        # Returns the classes that inherit from AngryMob::Target
        def subclasses
          @subclasses ||= {}
        end

        # Returns the files where the subclasses are kept.
        def subclass_files
          @subclass_files ||= Hash.new{ |h,k| h[k] = [] }
        end

        # Whenever a class inherits from AngryMob::Target, we should track the
        # class and the file on AngryMob::Target::Tracking. This is the method responsable for it.
        #
        def register_klass_file(klass) #:nodoc:
          file = caller[1].match(/(.*):\d+/)[1]

          nickname = klass.nickname.to_s
          AngryMob::Target::Tracking.subclasses[nickname] = klass unless AngryMob::Target::Tracking.subclasses.key?(nickname)

          file_subclasses = AngryMob::Target::Tracking.subclass_files[File.expand_path(file)]
          file_subclasses << klass unless file_subclasses.include?(klass)
        end
      end

      module ClassMethods
        # Everytime someone inherits from a AngryMob::Target class, register the klass
        # and file into baseclass.
        def inherited(klass)
          AngryMob::Target::Tracking.register_klass_file(klass)
        end

        # Fire this callback whenever a method is added. Added methods are
        # tracked as tasks by invoking the create_task method.
        def method_added(meth)
          meth = meth.to_s

          if meth == "initialize"
            initialize_added
            return
          end

          # Return if it's not a public instance method
          return unless public_instance_methods.include?(meth) ||
                        public_instance_methods.include?(meth.to_sym)

          return unless create_action(meth)

          #is_thor_reserved_word?(meth, :task)
          AngryMob::Target::Tracking.register_klass_file(self)
        end

        def nickname(name=nil)
          if name
            @nickname = name
            AngryMob::Target::Tracking.register_klass_file(self)
          else
            if @nickname
              @nickname
            else
              Util.snake_case(to_s)
            end
          end
        end

        protected

        # Retrieves a value from superclass. If it reaches the baseclass,
        # returns default.
        def from_superclass(method, default=nil)
          if self == baseclass || !superclass.respond_to?(method, true)
            default
          else
            value = superclass.send(method)
            value.dup if value
          end
        end


        def create_action(meth)
        end

        def initialize_added
        end

      end
    end
  end
end
