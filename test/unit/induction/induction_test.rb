require 'test/unit'
require 'stamina'
require 'stamina/induction/union_find'
require 'stamina/induction/commons'
module Stamina
  module Induction
    class InductionTest < Test::Unit::TestCase
      include Stamina::Induction::Commons
      
      # Asserts that two states are equivalent and recurse.
      def equivalent_states!(s1, s2, equivalences)
        return "#{s1.index} and #{s2.index} don't agree on flags" \
          unless s1.initial? == s2.initial? \
             and s1.accepting? == s2.accepting? \
             and s1.error? == s2.error?
        return "#{s1.index} and #{s2.index} don't agree on out symbols #{s1.out_symbols.inspect} #{s2.out_symbols.inspect}"\
          unless s1.out_symbols.sort == s2.out_symbols.sort
        equivalences[s1.index] = s2.index
        s1.out_symbols.each do |symbol|
          s1_target = s1.dfa_step(symbol)
          s2_target = s2.dfa_step(symbol)
          return false if (s1_target.nil? or s2_target.nil?)
          if equivalences.has_key?(s1_target.index)
            return "#{s1.index} and #{s2.index} don't agree on #{symbol}"\
              unless equivalences[s1_target.index]==s2_target.index
          else
            return msg \
              if msg=equivalent_states!(s1_target, s2_target, equivalences)
          end
        end
        nil
      end
      
      # Checks if two DFAs are equivalent.
      def equivalent?(dfa1, dfa2)
        return "not same number of states" unless dfa1.state_count==dfa2.state_count
        equivalent_states!(dfa1.initial_state, dfa2.initial_state, {})
      end
      
      # Puts a PTA under @pta
      def setup
        @sample = Stamina::ADL.parse_sample <<-EOF
          +
          - a
          - a a
          + a b
          - b a b a
          + b a b b
          + b b
        EOF
        @pta = sample2pta(@sample)
      end
      
      # Returns index-th state of the PTA
      def s(index)
        @pta.ith_state(index)
      end
      
      # Factors a UnionFind instance from the PTA under @pta.
      def factor_ufds
        pta2ufds(@pta)
      end
      
      # Just to avoid a stupid ruby error on empty test units.
      def test_empty
      end
      
    end
  end # module Induction
end # module Stamina
