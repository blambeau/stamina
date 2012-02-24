module Stamina
  class RegLang
    class ParserTest < Test::Unit::TestCase

      def test_regexp
        assert Parser.parse("a")
        assert Parser.parse("a+")
        assert Parser.parse("a b")
        assert Parser.parse("(a b)*")
        assert Parser.parse("(a | b)+")
        assert Parser.parse("   (a | b)+   ")
      end

      def test_sequence
        match = Parser.parse("a b c", :root => :sequence)
        assert(match)
        assert_equal("a b c", match)

        match = Parser.parse("a b+ c", :root => :sequence)
        assert(match)
        assert_equal("a b+ c", match)
      end

      def test_alternative
        match = Parser.parse("a | b | c", :root => :alternative)
        assert(match)
        assert_equal("a | b | c", match)

        match = Parser.parse("a b+ | a* c", :root => :alternative)
        assert(match)
        assert_equal("a b+ | a* c", match)
      end

      def test_symbol
        match = Parser.parse("a", :root => :symbol)
        assert(match)
        assert_equal("a", match)

        match = Parser.parse("hello", :root => :symbol)
        assert(match)
        assert_equal("hello", match)
      end

      def test_star
        match = Parser.parse("a*", :root => :star)
        assert(match)
        assert_equal("a*", match)
      end

      def test_plus
        match = Parser.parse("a+", :root => :plus)
        assert(match)
        assert_equal("a+", match)
      end

      def test_question
        match = Parser.parse("a?", :root => :question)
        assert(match)
        assert_equal("a?", match)
      end

      def test_parenthesized
        match = Parser.parse("(a)", :root => :parenthesized)
        assert(match)
        assert_equal("(a)", match)

        match = Parser.parse("(a+)", :root => :parenthesized)
        assert(match)
        assert_equal("(a+)", match)

        match = Parser.parse("(a (b c)+ a*)", :root => :parenthesized)
        assert(match)
        assert_equal("(a (b c)+ a*)", match)
      end

    end # class ParserTest
  end # class RegLang
end # module Stamina