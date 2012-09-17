module Stamina
  module Utils
    class Aggregator

      def initialize
        @functions = {}
        @default   = nil
        yield(self) if block_given?
      end
      attr_reader :functions

      def register(key, function = nil, &bl)
        functions[key] = function || bl
      end

      def default(function = nil, &bl)
        @default = function || bl
      end

      def ignore(key)
        register(key, lambda{|v1,v2| throw :ignore })
      end

      def merge(t1, t2)
        tuple = {}
        t1.keys.each do |k|
          next unless fn = functions[k] || @default
          catch :ignore do
            tuple[k] = fn.call(t1[k], t2[k])
          end
        end
        tuple
      end

      def aggregate(enum)
        memo = nil
        enum.each do |tuple|
          memo = memo ? merge(memo, tuple) : tuple
        end
        memo
      end

    end # class Aggregator
  end # module Utils
end # module Stamina