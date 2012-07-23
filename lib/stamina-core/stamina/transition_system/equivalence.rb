module Stamina
  class TransitionSystem
    class Equivalence

      # Returns true if `s` and `t` must be considered equivalent, false otherwise.
      def equivalent_systems?(s, t)
        (s.state_count == t.state_count) &&
        (s.edge_count  == t.edge_count)  &&
        (s.raw_data    == t.raw_data)
      end

      def equivalent_systems!(s, t)
        fail "Non equivalent systems `#{s}` and `#{t}`" unless equivalent_systems?(s,t)
        true
      end

      # Returns true if `s` and `t` must be considered equivalent, false otherwise.
      def equivalent_states?(s, t)
        s.raw_data == t.raw_data
      end

      def equivalent_states!(s, t)
        fail "Non equivalent states `#{s}` and `#{t}`" unless equivalent_states?(s,t)
        true
      end

      # Returns true if `e` and `f` must be considered equivalent, false otherwise.
      def equivalent_edges?(e, f)
        e.raw_data == f.raw_data
      end

      def equivalent_edges!(s, t)
        fail "Non equivalent edges `#{s}` and `#{t}`" unless equivalent_edges?(s,t)
        true
      end

      # Finds the edge counterpart of `operand_edge` as an outgoing edge of
      # `reference_state`. The default implementation takes an edge that shares the same
      # symbol as operand_edge.
      def find_edge_counterpart(reference_state, operand_edge)
        symbol = operand_edge.symbol
        reference_state.out_edges.find{|e| e.symbol==symbol}
      end

      # Computes equivalence pairs through decoration
      class EquivThroughDeco < Utils::Decorate
        
        def initialize(reference, algo)
          @reference = reference
          @algo      = algo
        end
        attr_reader :reference, :algo

        def suppremum(d0, d1)
          return (d0 || d1) if (d0.nil? or d1.nil?)
          unless d0==d1
            algo.fail("Different states found through same path: #{d0} & #{d1}")
          end
          d0
        end

        def propagate(deco, edge)
          symbol   = edge.symbol
          source   = reference.ith_state(deco)
          eq_edge  = algo.find_edge_counterpart(source, edge)
          algo.fail("No such transition `#{symbol}` from #{source}") unless eq_edge
          algo.equivalent_edges!(edge, eq_edge)
          algo.equivalent_states!(edge.target, eq_edge.target)
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
      def call(ts1, ts2, &explain)
        @explain = explain
        catch(:fail) do
          equivalent_systems!(ts1, ts2)
          i1, i2 = ts1.initial_state, ts2.initial_state
          fail "No initial state on ts1" unless i1
          fail "No initial state on ts2" unless i2
          equivalent_states!(i1, i2)
          EquivThroughDeco.new(ts2, self).call(ts1, {})
          return true
        end
        return false
      ensure
        @explain = nil
      end

      def fail(message)
        @explain.call(message) if @explain
        throw :fail
      end

    end # class Equivalence
  end # class TransitionSystem
end # module Stamina