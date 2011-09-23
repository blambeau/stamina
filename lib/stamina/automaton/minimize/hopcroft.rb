module Stamina
  class Automaton
    module Minimize
      class Hopcroft

        # Creates an algorithm instance
        def initialize(automaton, options)
          raise ArgumentError, "Deterministic automaton expected", caller unless automaton.deterministic?
          @automaton = automaton
        end
        
        # Compute a Hash {symbol => state_group} from a group of states
        def reverse_delta(group)
          h = Hash.new{|h,k| h[k]=Set.new}
          group.each do |state|
            state.in_edges.each do |edge|
              h[edge.symbol] << edge.source
            end
          end
          h
        end
        
        # Computes a minimal dfa from the grouping information
        def compute_minimal_dfa(groups)
          indexes = []
          fa = Automaton.new do |fa|

            # create one state for each group
            groups.each_with_index do |group,index|
              group.each{|s| indexes[s.index] = index}
              data = group.inject(nil) do |memo,s|
                if memo.nil?
                  s.data
                else
                  {:initial   => memo[:initial]   || s.initial?,
                   :accepting => memo[:accepting] || s.accepting?,
                   :error     => memo[:error]     || s.error?}
                end
              end
              fa.add_state(data)
            end

            # connect transitions now
            groups.each_with_index do |group,index|
              group.each do |s|
                s_index = indexes[s.index]
                s.out_edges.each do |edge|
                  symbol, t_index = edge.symbol, indexes[edge.target.index]
                  unless fa.ith_state(s_index).dfa_step(symbol)
                    fa.connect(s_index, t_index, symbol)
                  end
                end
              end
            end

          end
          fa.drop_states *fa.states.select{|s| s.sink?}
          fa.state_count == 0 ? Automaton::DUM : fa
        end
        
        # Computes the initial partition
        def initial_partition
          p = [Set.new, Set.new]
          @automaton.states.each do |s|
            (s.accepting? ? p[0] : p[1]) << s
          end
          p.reject{|g| g.empty?}
        end
        
        # Main method of the algorithm
        def main
          # Partition states a first time according to accepting/non accepting
          @partition = initial_partition # P in pseudo code
          @worklist = @partition.dup     # W in pseudo code
          
          # Until a block needs to be refined
          until @worklist.empty?
            refined = @worklist.pop
            
            # We compute the reverse delta on the group and look at the groups
            rdelta = reverse_delta(refined)
            rdelta.each_pair do |symbol, sources| # sources is la in pseudo code
              
              # Find blocks to be refined
              @partition.dup.each_with_index do |block, index| # block is R in pseudo code
                next if block.subset?(sources)
                intersection = block & sources    # R1 in pseudo code
                next if intersection.empty?
                difference = block - intersection # R2 in pseudo code
                
                # replace R in P with R1 and R2
                @partition[index] = intersection
                @partition << difference
                
                # Adds the new blocks as to be refined
                if @worklist.include?(block)
                  @worklist.delete(block)
                  @worklist << intersection << difference
                else
                  @worklist << (intersection.size <= difference.size ? intersection : difference)
                end
              end # @partition.each
              
            end # rdelta.each_pair
          end # until @worklist.empty?
          
          compute_minimal_dfa(@partition)
        end # def main
        
        # Execute the minimizer
        def self.execute(automaton, options={})
          Hopcroft.new(automaton.strip.complete!, options).main
        end
      
      end # class Hopcroft
    end # module Minimize
  end # class Automaton
end # module Stamina
