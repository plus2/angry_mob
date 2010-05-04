
class AngryMob
  class Target
    module Tracking
      class << self
        def included(base) #:nodoc:
          base.send :extend,  ClassMethods
          base.send :include, Invocation
          base.send :include, Shell
        end

        # Returns the classes that inherit from AngryMob::Target
        def subclasses
          @subclasses ||= []
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
          AngryMob::Target::Tracking.subclasses << klass unless AngryMob::Target::Tracking.subclasses.include?(klass)

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

          return if @no_tasks || !create_task(meth)

          #is_thor_reserved_word?(meth, :task)
          AngryMob::Target::Tracking.register_klass_file(self)
        end

      end
    end
  end
end
