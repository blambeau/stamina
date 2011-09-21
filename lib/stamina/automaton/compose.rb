module Stamina
  class Automaton
    class Compose

      # Automata under composition
      attr_reader :automata

      def initialize(automata)
        @automata = automata.collect{|a|
          a.deterministic? ? a : a.determinize
        }
      end

      def marks(compound, initial = false)
        {:initial   => initial,
         :accepting => compound.all?{|s| s.accepting?},
         :error     => compound.any?{|s| s.error?}
        }
      end

      def main
        # Map every symbol to concerned automata
        symbols = Hash.new{|h,k| h[k] = []}

        # The compound initial state
        init = []

        # Build the symbol table and prepare the initial state
        automata.each_with_index do |fa,i|
          fa.alphabet.each{|l| symbols[l][i] = fa}
          init << fa.initial_state
        end

        # Compound automaton and states already seen
        compound_fa = Automaton.new
        map = {init => compound_fa.add_state(marks(init, true))}
        
        # States to be visited
        to_visit = [init]
        
        until to_visit.empty?
          source = to_visit.pop
          symbols.each_pair do |symbol, automata|
            catch(:avoid) do
              # build the target state
              target = source.zip(automata).collect{|ss,a|
                if a.nil? 
                  # this automaton does no synchronize on symbol
                  ss
                elsif tt = ss.dfa_delta(symbol)
                  # it synchronizes and target has been found
                  tt
                else
                  # it synchronizes but target has not been found
                  throw :avoid
                end
              }
              unless map.has_key?(target)
                map[target] = compound_fa.add_state(marks(target))
                to_visit << target
              end
              compound_fa.connect(map[source],map[target],symbol)
            end
          end
        end # to_visit.empty?
        
        compound_fa
      end

      def self.execute(automata)
        Compose.new(automata).main
      end

    end # class Compose

    def compose(*automata)
      Automaton::Compose.execute([self] + automata)
    end

  end # class Automaton
end # module Stamina

#      class CompoundState
#        include Enumerable
#        attr_reader   :states
#        
#        def initialize(states)
#          @states = states
#        end
#        
#        def hash
#          states.hash
#        end
#        
#        def ==(other)
#          other.states == states
#        end
#        alias :eql? :other
#        
#        def marks(initial = false)
#          {:initial   => initial,
#           :accepting => states.all?{|s| s.accepting?},
#           :error     => states.any?{|s| s.error?}
#          }
#        end
#        
#        def each
#          states.each &Proc.new
#        end
#        
#      end
