module Stamina
  class Automaton
    class ComposeTest < StaminaTest

      def compose(*automata)
        Automaton::Compose.execute(automata)
      end

      def fa(x)
        RegLang.parse(x).to_fa
      end

      def test_compose_on_equivalent_dfas
        ab_star_1 = fa("(a b)*")
        ab_star_2 = fa("(a b)*")
        expected  = fa("(a b)*")
        assert compose(ab_star_1, ab_star_2).to_cdfa <=> expected.to_cdfa
      end

      def test_compose_on_subset_dfas_1
        master = fa("(a b)* | a (b a)*")
        subset = fa("(a b)*")
        assert compose(master, subset).to_cdfa <=> subset.to_cdfa
      end

      def test_compose_on_dfas_same_alph
        x = fa("((a | b) c)*")
        y = fa("(a b* c)*")
        expected = fa("(a c)*")
        assert compose(x, y).to_cdfa <=> expected.to_cdfa
      end

      def test_compose_on_independent_dfas
        x = fa("a*")
        y = fa("b*")
        expected = fa("(a | b)*")
        assert compose(x, y).to_cdfa <=> expected.to_cdfa
      end

    end
  end
end