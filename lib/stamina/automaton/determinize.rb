module Stamina
  class Automaton
    class Determinize

      class CompoundState

        attr_reader :fa
        attr_reader :states
        attr_reader :initial

        def initialize(fa, states, initial = false)
          @fa = fa
          @states = states.sort
          @initial = initial
        end

        def marks
          @marks ||= begin
            marks = {}
            marks[:initial] = initial
            marks[:accepting] = states.any?{|s| s.accepting?}
            marks[:error] = states.any?{|s| s.error?}
            marks
          end
        end

        def delta(symbol)
          CompoundState.new(fa, fa.delta(states, symbol))
        end

        def hash
          @states.hash
        end

        def ==(other)
          other.is_a?(CompoundState) &&
          (other.fa == self.fa) &&
          (other.states == self.states)
        end
        alias :eql? :==

      end # class CompoundState

      attr_reader :fa
      attr_reader :options

      def initialize(fa, options)
        @fa = fa
        @options = options
      end

      def main
        # the alphabet
        alph = fa.alphabet

        # the minimized automaton
        minimized = Automaton.new
        
        # - map between compound states and minimized states 
        # - states to visit
        map = {}
        to_visit = []

        # initial state and mark as to visit
        init = CompoundState.new(fa, fa.initial_states, true)
        map[init] = minimized.add_state(init.marks)
        to_visit  = [init]
        
        until to_visit.empty?
          current = to_visit.pop
          alph.each do |symbol|
            found = current.delta(symbol)
            unless map.has_key?(found)
              map[found] = minimized.add_state(found.marks)
              to_visit << found
            end
            minimized.connect(map[current], map[found], symbol)
          end
        end

        minimized
      end

      def self.execute(fa, options = {})
        Determinize.new(fa, options).main
      end

    end # class Determinize

    #
    # Determinizes this automaton by removing explicit non-determinism as well
    # as all espilon moves.
    #
    def determinize
      Determinize.execute(self)
    end

  end # class Automaton
end # module Stamina
