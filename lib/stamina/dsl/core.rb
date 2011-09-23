module Stamina
  module Dsl
    module Core

      def assert(x, msg = nil)
        raise Stamina::AssertionError, 
              "Assertion failed: #{msg || 'no message provided'}",
              caller unless x
      end

    end # module Core
    include Core
  end # module Dsl
end # module Stamina
