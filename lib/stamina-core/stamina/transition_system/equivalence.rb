module Stamina
  class TransitionSystem
    class Equivalence

      # Returns true if `s` and `t` must be considered equivalent, false otherwise.
      def equivalent_systems?(s, t)
        (s.state_count == t.state_count) &&
        (s.edge_count  == t.edge_count)  &&
        (s.data        == t.data)
      end

      # Returns true if `s` and `t` must be considered equivalent, false otherwise.
      def equivalent_states?(s, t)
        s.data == t.data
      end

      # Returns true if `e` and `f` must be considered equivalent, false otherwise.
      def equivalent_edges?(e, f)
        e.data == f.data
      end

      # Computes equivalence pairs through decoration
      class EquivThroughDeco < Utils::Decorate
        
        def initialize(algo, reference)
          @algo      = algo
          @reference = reference
        end
        attr_reader :reference, :algo

        def suppremum(d0, d1)
          return (d0 || d1) if (d0.nil? or d1.nil?)
          throw :not_equivalent unless d0==d1
          d0
        end

        def propagate(deco, edge)
          symbol   = edge.symbol
          eq_edge  = reference.ith_state(deco).out_edges.find{|e| e.symbol==symbol}
          throw :non_equivalent unless eq_edge && algo.equivalent_edges?(edge, eq_edge)
          throw :non_equivalent unless algo.equivalent_states?(edge.target, eq_edge.target)
          eq_edge.target.index
        end

        def init_deco(s)
          s.initial? ? reference.initial_state.index : nil
        end

        def take_at_start?(s)
          s.initial?
        end

      end # EquivThroughDeco

      # Executes the equivalence algorithm on two transition systems `ts1` and `ts2`.
      # Returns true if they are considered equivalent, false otherwise.
      def call(ts1, ts2)
        return false unless equivalent_systems?(ts1, ts2)
        return false unless equivalent_states?(ts1.initial_state, ts2.initial_state)
        catch(:non_equivalent) do
          EquivThroughDeco.new(self, ts2).call(ts1, {})
          return true
        end
        return false
      end

    end # class Equivalence
  end # class TransitionSystem
end # module Stamina