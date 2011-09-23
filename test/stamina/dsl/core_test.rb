require 'stamina/stamina_test'
module Stamina
  module Dsl
    class CoreTest < StaminaTest
      include Stamina::Dsl
    
      def test_assert
        assert_nothing_raised{ assert(true, "no error") }
        assert_raise(Stamina::AssertionError){ assert(false, "an error") }
      end

    end
  end
end
