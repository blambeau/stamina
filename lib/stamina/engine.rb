require "stamina/engine/context"
require "stamina/engine/dsl"
module Stamina
  class Engine
    include Engine::DSL

    def self.execute(__code__)
      new.instance_eval <<-EOF
        main = begin
          #{__code__}
        end
        Context.new(local_variables - [:__code__], binding)
      EOF
    end

  end # class Engine
end # module Stamina
