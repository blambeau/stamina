module Stamina
  module Induction
    
    #
    # Defines common utilities used by rpni and blue_fringe. About acronyms: 
    # - _pta_ stands for Prefix Tree Acceptor
    # - _ufds_ stands for Union-Find Data Structure
    #
    # Methods pta2ufds, sample2pta and sample2ufds are simply conversion methods used
    # when the induction algorithm starts (executed on a sample, it first built a pta 
    # then convert it to a union find). Method ufds2pta is used when the algorithm ends, 
    # to convert refined union find to a dfa.
    #
    # The merge_user_data method is probably the most important as it actually computes 
    # the merging of two states and build information about merging for determinization.
    #
    module Commons
      
      #
      # Factors and returns a UnionFind data structure from a PTA, keeping natural order 
      # of its states for union-find elements. The resulting UnionFind contains a Hash as 
      # mergeable user data, presenting the following keys:
      # - :initial, :accepting and :error flags of each state
      # - :master indicating the index of the state in the PTA
      # - :delta a delta function through a Hash {symbol => state_index}
      #
      # In this version, other user data attached to PTA states is lost during the 
      # conversion.
      #
      def pta2ufds(pta)
        Stamina::Induction::UnionFind.new(pta.state_count) do |i|
          state = pta.ith_state(i)
          data = {:initial => state.initial?,
                  :accepting => state.accepting?,
                  :error => state.error?,
                  :master => i,
                  :delta => {}}
          state.out_edges.each {|edge| data[:delta][edge.symbol] = edge.target.index}
          data
        end
      end
      
      #
      # Converts a Sample to an (augmented) prefix tree acceptor. This method ensures 
      # that the states of the PTA are in lexical order, according to the <code><=></code>
      # operator defined on symbols. States reached by negative strings are tagged as
      # non accepting and error.
      #
      def sample2pta(sample)
        Automaton.new do |pta|
          initial_state = add_state(:initial => true, :accepting => false)

          # Fill the PTA with each string
          sample.each do |str|
            # split string using the dfa
            parsed, reached, remaining = pta.dfa_split(str, initial_state)
      
            # remaining symbols are not empty -> build the PTA
            unless remaining.empty?
              remaining.each do |symbol|
                newone = pta.add_state(:initial => false, :accepting => false, :error => false)
                pta.connect(reached, newone, symbol)
                reached = newone
              end
            end
      
            # flag state      
            str.positive? ? reached.accepting! : reached.error!
            
            # check consistency, should not arrive as Sample does not allow
            # inconsistencies. Should appear only if _sample_ is not a Sample
            # instance but some other enumerable.
            raise(InconsistencyError, "Inconsistent sample on #{str}", caller)\
              if (reached.error? and reached.accepting?)
          end

          # Reindex states by applying BFS
          to_index, index = [initial_state], 0
          until to_index.empty?
            state = to_index.shift
            state[:__index__] = index
            state.out_edges.sort{|e,f| e.symbol<=>f.symbol}.each {|e| to_index << e.target} 
            index += 1 
          end
          # Force the automaton to reindex
          pta.order_states{|s0,s1| s0[:__index__]<=>s1[:__index__]}
          # Remove marks
          pta.states.each{|s| s.remove_mark(:__index__)}
        end
      end

      #
      # Converts a Sample instance to a 'ready to refine' union find data structure.
      # This method is simply a shortcut for <code>pta2ufds(sample2pta(sample))</code>.
      #
      def sample2ufds(sample)
        pta2ufds(sample2pta(sample))
      end

      # 
      # Computes the quotient automaton from a refined UnionFind data structure.
      #
      # In this version, only accepting and initial flags are taken into account
      # when creating quotient automaton states. Other user data is lost during 
      # the conversion.
      #
      def ufds2dfa(ufds)
        Automaton.new(false) do |fa|
          mergeable_datas = ufds.mergeable_datas
          mergeable_datas.each do |data|
            state_data = data.reject {|key,value| [:master, :count, :delta].include?(key)}
            state_data[:name] = data[:master].to_s
            state_data[:error] = false
            fa.add_state(state_data)
          end
          mergeable_datas.each do |data|
            source = fa.get_state(data[:master].to_s)
            data[:delta].each_pair do |symbol, target|
              target = fa.get_state(ufds.find(target).to_s)
              fa.connect(source, target, symbol)
            end
          end
        end
      end
      
      #
      # Merges two user data hashes _d1_ and _d2_ according to rules defined
      # below. Also fills a _determinization_ array with pairs of state indices
      # that are reached from d1 and d2 through the same symbol and should be 
      # merged for determinization. This method does NOT ensure that those pairs
      # correspond to distinguish states according to the union find. In other
      # words state indices in these pairs do not necessarily corespond to master
      # states (see UnionFind for this term).
      #
      # Returns the resulting data if the merge is successful (does not lead to
      # merging an error state with an accepting one), nil otherwise.
      #
      # The merging procedure for the different hash keys is as follows:
      # - result[:initial]   =  d1[:initial]   or d2[:initial]
      # - result[:accepting] =  d1[:accepting] or d2[:accepting]
      # - result[:error]     =  d1[:error]     or d2[:error]
      # - result[:master]    =  min(d1[:master], d2[:master])
      # - result[:delta]     =  merging of delta hashes, keeping smaller target index 
      #   on key collisions.
      #
      def merge_user_data(d1, d2, determinization)
        # we compute flags first
        new_data = {:initial => d1[:initial] || d2[:initial], 
                    :accepting => d1[:accepting] || d2[:accepting],
                    :error => d1[:error] || d2[:error],
                    :master => d1[:master] < d2[:master] ? d1[:master] : d2[:master]}
                
        # merge failure if accepting and error states are merged
        return nil if new_data[:accepting] and new_data[:error]
                
        # we recompute the delta function of the resulting state
        # keeping merging for determinization as pairs in _determinization_
        new_data[:delta] = d1[:delta].merge(d2[:delta]) do |symbol, t1, t2|
          determinization << [t1, t2]
          t1 < t2 ? t1 : t2
        end
        
        # returns merged data
        new_data
      end
      
    end # module Commons
    
  end # module Induction
end # module Stamina
