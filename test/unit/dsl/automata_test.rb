require 'stamina_test'
module Stamina
  module Dsl
    class AutomataTest < StaminaTest
      include Stamina::Dsl
    
      def test_automaton
        expected = Automaton.new do 
          add_state :initial => true, :accepting => true
          add_state :initial => false, :accepting => false
          connect(0,1,"a")
          connect(1,0,"b")
        end
        assert expected.equivalent?(automaton(expected))
        code = <<-EOF
          2 2
          0 true true
          1 false false
          0 1 a
          1 0 b
        EOF
        assert expected.equivalent?(automaton(code))
      end

    end
  end
end
