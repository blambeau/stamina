module Stamina
  class RegLang
    class ParserTest < Test::Unit::TestCase

      def test_symbol
        match = Parser.parse("a", :root => :symbol)
        expected = Automaton.new do
          add_state(:initial => true, :accepting => false)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

      def test_question
        match = Parser.parse("a?", :root => :question)
        expected = Automaton.new do
          add_state(:initial => true, :accepting => true)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

      def test_plus
        match = Parser.parse("a+", :root => :plus)
        expected = Automaton.new do
          add_state(:initial => true,  :accepting => false)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
          connect(1,1,"a")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

      def test_star
        match = Parser.parse("a*", :root => :star)
        expected = Automaton.new do
          add_state(:initial => true,  :accepting => true)
          connect(0,0,"a")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

      def test_sequence_1
        match = Parser.parse("a", :root => :sequence)
        expected = Automaton.new do
          add_state(:initial => true,  :accepting => false)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

      def test_sequence_2
        match = Parser.parse("a b c", :root => :sequence)
        expected = Automaton.new do
          add_state(:initial => true,  :accepting => false)
          add_state(:initial => false, :accepting => false)
          add_state(:initial => false, :accepting => false)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
          connect(1,2,"b")
          connect(2,3,"c")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

      def test_alternative_1
        match = Parser.parse("a", :root => :alternative)
        expected = Automaton.new do
          add_state(:initial => true,  :accepting => false)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

      def test_alternative_2
        match = Parser.parse("a | b | c", :root => :alternative)
        expected = Automaton.new do
          add_state(:initial => true,  :accepting => false)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
          connect(0,1,"b")
          connect(0,1,"c")
        end
        assert match.to_fa.canonical <=> expected.canonical
      end

    end # class ParserTest
  end # class RegLang
end # module Stamina
