require 'test/unit'
require 'stamina'
module Stamina

  #
  # Main test class for stamina. By default this test installs default example
  # automata on setup.
  #
  # In particular, it installs the following automata:
  # - @small_dfa: a small deterministic automaton whose picture can be found in
  #   small_dfa.gif
  # - @small_nfa: a small non deterministic automaton whose picture can be found
  #   in small_nfa.gif
  #
  # Moreover, is also provides the following helpers:
  # - @examples is an array containing all created automata.
  # - @dfa_examples is an array containing deterministic automaton only.
  # - @nfa_examples is an array containing non-deterministic automaton only.
  #
  class StaminaTest < Test::Unit::TestCase

    def load_adl_automaton(file, resolver)
      Stamina::ADL.parse_automaton_file(File.expand_path("../#{file}", resolver))
    end

    # Creates a small automaton for the sake of simple tests
    def setup
      @small_dfa = Automaton.new do
        s0, s1, s2, s3 = add_n_states(4)
        s3.initial!
        s0.accepting!
        s2.accepting!
        connect(s0, s1, 'a')
        connect(s1, s2, 'b')
        connect(s1, s3, 'a')
        connect(s3, s2, 'b')
        connect(s2, s0, 'c')
        connect(s1, s1, 'c')
      end

      @small_nfa = Automaton.new do
        s0, s1, s2, s3 = add_n_states(4)
        s0.initial!
        s3.initial!
        s0.accepting!
        s2.accepting!
        connect(s0, s1, 'a')
        connect(s1, s1, nil)
        connect(s1, s2, 'b')
        connect(s1, s3, 'b')
        connect(s2, s3, 'c')
        connect(s3, s0, 'a')
        connect(s2, s1, nil)
      end

      @examples = [@small_dfa, @small_nfa]
      @dfa_examples = [@small_dfa]
      @nfa_examples = [@small_nfa]
    end

    # Returns an automaton recognizing (ab)*
    def ab_star
      Automaton.new(true) do |fa|
        fa.alphabet = ["a", "b"]
        fa.add_state(:initial => true,  :accepting => true)
        fa.add_state(:initial => false, :accepting => false)
        fa.connect(0,1,'a')
        fa.connect(1,0,'b')
      end
    end

    # Returns an automaton recognizing a*
    def a_star
      Automaton.new(true) do |fa|
        fa.alphabet = ["a"]
        fa.add_state(:initial => true,  :accepting => true)
        fa.connect(0,0,'a')
      end
    end

    # Returns an automaton recognizing b*
    def b_star
      Automaton.new(true) do |fa|
        fa.alphabet = ["b"]
        fa.add_state(:initial => true,  :accepting => true)
        fa.connect(0,0,'b')
      end
    end

    # Tests the validity of examples
    def test_validity_of_examples
      @dfa_examples.each do |e|
        assert_equal(true, e.deterministic?)
      end
      @nfa_examples.each do |e|
        assert_equal(false, e.deterministic?)
      end
    end

    def assert_not_equivalent(expected, dfa)
      assert !expected.complete.equivalent?(dfa.complete)
    end

    def assert_equivalent(expected, dfa)
      assert expected.complete.equivalent?(dfa.complete)
    end

  end # class StaminaTest
end # module Stamina