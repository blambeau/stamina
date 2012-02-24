module Stamina
  class EngineTest < StaminaTest

    def test_execute_with_local_vars
      context = Engine.execute <<-EOF
        a = 1
        b = 2 * a
      EOF
      assert_equal({:a => 1, :b => 2, :main => 2}, context.to_h)
    end

    def test_execute_with_dsl_calls
      context = Engine.execute <<-EOF
        regular "(start stop)*"
      EOF
      assert context[:main].is_a?(Stamina::RegLang)
    end

  end # class EngineTest
end # module Stamina