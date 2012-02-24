module Stamina
  class Engine
    class Context
      include Enumerable

      attr_reader :vars, :binding

      def initialize(vars, binding)
        @vars = vars.collect{|v| v.to_sym}
        @binding = binding
      end

      def each
        vars.each do |key|
          yield(key, self[key])
        end
      end

      def [](name)
        binding.eval(name.to_s)
      end

      def to_h
        Hash[collect{|k,v| [k,v]}]
      end

      def to_s
        collect{|k,v|
          "#{k}: #{v}"
        }.join("\n")
      end

    end # class Context
  end # class Engine
end # module Stamina