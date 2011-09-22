module Stamina
  class Engine
    class Context
      include Enumerable

      attr_reader :vars, :binding

      def initialize(vars, binding)
        @vars = vars
        @binding = binding
      end

      def each
        vars.each &Proc.new
      end

      def [](name)
        binding.eval(name.to_s)
      end

      def to_h
        Hash[collect{|v| [v,self[v]]}]
      end

      def to_s
        vars.collect{|v| 
          "#{v}: #{self[v]}"
        }.join("\n")
      end

    end # class Context
  end # class Engine
end # module Stamina
