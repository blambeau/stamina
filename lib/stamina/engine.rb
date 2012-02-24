require "stamina/engine/context"
module Stamina
  class Engine
    include Stamina::Dsl

    def execute_binding
      binding
    end

    def execute(code, file = nil)
      code = <<-EOF
        main = begin
          #{code}
        end
        Context.new(local_variables, binding)
      EOF
      if file
        eval(code, execute_binding, file)
      else
        eval(code, execute_binding)
      end
    end

    def self.execute(*args)
      new.execute(*args)
    end

  end # class Engine
end # module Stamina