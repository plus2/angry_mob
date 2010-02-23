class AngryMob
  class Node < Struct.new(:name,:attributes)
    def targets
      @targets ||= []
    end

    def method_missing(method,*args,&block)
      puts "Node mm #{method}"
      # TODO - autovivification, tree-like, or Hashie::Mash

      # gulp
    end
  end
end
