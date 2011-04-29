module Stamina
  module Induction
    
    #
    # Implementation of the BlueFringe variant of the RPNI algorithm (with the blue-fringe
    # heuristics).
    #
    # See Lang, K., B. Pearlmutter, andR. Price. 1998. Results of the Abbadingo One DFA
    # Learning Competition and a New Evidence-Driven State Merging Algorithm, In Grammatical 
    # Inference, pp. 1–12. Ames, IO: Springer-Verlag.
    #
    # Example:
    #   # sample typically comes from an ADL file
    #   sample = Stamina::ADL.parse_sample_file('sample.adl')
    #
    #   # let BlueFringe build the smallest dfa
    #   dfa = Stamina::Induction::BlueFringe.execute(sample, {:verbose => true})
    #
    # Remarks:
    # - Constructor and instance methods of this class are public but not intended 
    #   to be used directly. They are left public for testing purposes only.
    # - Having read the Stamina::Induction::BlueFringe base algorithm may help undertanding
    #   this variant.
    # - This class intensively uses the Stamina::Induction::UnionFind class and 
    #   methods defined in the Stamina::Induction::Commons module which are worth
    #   reading to understand the algorithm implementation.
    #
    class BlueFringe
      include Stamina::Induction::Commons
      
      # Union-find data structure used internally
      attr_reader :ufds
      
      # Creates an algorithm instance with given options.
      def initialize(options={})
        raise ArgumentError, "Invalid options #{options.inspect}" unless options.is_a?(Hash)
        @options = DEFAULT_OPTIONS.merge(options)
      end

      #
      # Computes the score of a single (group) merge. Returned value is 1 if both are 
      # accepting states or both are error states and 0 otherwise. Note that d1 and d2
      # are expected to be merge compatible as this method does not distinguish this 
      # case.  
      #
      def merge_score(d1, d2)
        # Score of 1 if both accepting or both error
        ((d1[:accepting] and d2[:accepting]) or (d1[:error] and d2[:error])) ? 1 : 0
      end
      
      #
      # Merges a state of rank j with a state of lower rank i. This merge method 
      # includes merging for determinization. It returns nil if the merge is 
      # incompatible, a merge score otherwise.
      #
      # Preconditions:
      # - States denoted by i and j are expected leader states (non merged ones)
      # - States denoted by i and j are expected to be different
      #
      # Postconditions:
      # - Union find is refined, states i and j having been merged, as well as all
      #   state pairs that need to be merged to ensure the deterministic property
      #   of the quotient automaton.
      # - If the resulting quotient automaton is consistent with the negative sample, 
      #   this method returns the number of accepting pairs + the number of error pairs 
      #   that have been merged. The refined union-find correctly encodes the quotient 
      #   automaton. Otherwise, the method returns nil and the union-find information 
      #   must be considered inaccurate.
      #
      def merge_and_determinize(i, j)
        # Make the union (keep merging score as well as additional merges to be performed
        # in score and determinization, respectively). Recompute the user data attached to 
        # the new state group (new_data)
        determinization, score = [], nil
        @ufds.union(i, j) do |d1, d2|
          # states are incompatible if new_data cannot be created because it would
          # lead to merge and error and an accepting state. We simply return nil in this
          # case...
          return nil unless (new_data = merge_user_data(d1, d2, determinization))
          # otherwise, we score
          score = merge_score(d1, d2)
          # and we let the union find keep the new_data for the group
          new_data
        end
        
        # Merge for determinization starts here, based on the determinization array
        # computed as a side effect of merge_user_data
        determinization.each do |pair|
          # we take the leader states of the pair to merge
          pair = pair.collect{|i| @ufds.find(i)} 
          # do nothing if already the same leader state
          next if pair[0]==pair[1]
          # otherwise recurse and keep subscore
          subscore = merge_and_determinize(pair[0], pair[1]) 
          # failure if merging for determinization led to merge error and accepting 
          # states
          return nil if subscore.nil?
          # this is the new score
          score += subscore
        end

        score
      end
      
      #
      # Evaluates the score of merging states i and j. Returns nil if the states are
      # cannot be merged, a positive score otherwise.
      #
      # Preconditions:
      # - States denoted by i and j are expected leader states (non merged ones)
      # - States denoted by i and j are expected to be different
      #
      # Postconditions:
      # - Returned value is nil if the quotient automaton would be incompatible with 
      #   the sample. Otherwise a positive number is returned, encoding the number of
      #   interresting pairs that have been merged (interesting = both accepting or both
      #   error)
      # - The union find is ALWAYS restored to its previous value after merging has 
      #   been evaluated and is then seen unchanged by the caller.
      #
      def merge_and_determinize_score(i, j)
        # score the merging, always rollback the transaction
        score = nil
        @ufds.transactional do
          score = merge_and_determinize(i, j)
          false
        end
        score
      end

      #
      # Computes the fringe given the current union find. The fringe is returned as an
      # array of state indices.
      #
      # Postconditions:
      # - Returned array contains indices of leader states only.
      # - Returned array is disjoint with the kernel.
      #
      def fringe
        fringe = []
        @kernel.each do |k1|
          delta = @ufds.mergeable_data(k1)[:delta]
          delta.each_pair{|symbol, target| fringe << @ufds.find(target)}
        end
        (fringe - @kernel).sort
      end
      
      #
      # Main method of the algorithm. Refines the union find passed as first argument 
      # by merging well chosen state pairs. Returns the refined union find.
      #
      # Preconditions:
      # - The union find _ufds_ is correctly initialized (contains :initial, :accepting,
      #   and :error boolean flags as well as a :delta sub hash)
      #
      # Postconditions:
      # - The union find has been refined. It encodes a quotient automaton (of the PTA
      #   it comes from) such that all positive and negative strings of the underlying
      #   sample are correctly classified by it.
      #
      def main(ufds)
        info("Starting BlueFringe (#{ufds.size} states)")
        @ufds, @kernel = ufds, [0]
        
        # we do it until the fringe is empty (compute it only once each step)
        until (the_fringe=fringe).empty?
          # state to consolidate (if any)
          to_consolidate = nil
          # best candidate [source index, target index, score]
          best = [nil, nil, -1]
          
          # for each state on the fringe as merge candidate
          the_fringe.each do |candidate|
            to_consolidate = candidate
            
            # evaluate score of merging candidate with each kernel state
            @kernel.each do |target|
              score = merge_and_determinize_score(candidate, target)
              unless score.nil?
                # if a score has been found, the candidate will not be 
                # consolidated. We keep it as best if its better than the
                # previous one
                to_consolidate = nil
                best = [candidate, target, score] if score > best[2]
              end
            end
            
            # No possible target, break the loop (will consolidate right now)!
            break unless to_consolidate.nil?
          end
          
          # If not found, the last candidate must be consolidated. Otherwise, we 
          # do the best merging
          unless to_consolidate.nil?
            info("Consolidation of #{to_consolidate}")
            @kernel << to_consolidate
          else
            info("Merging #{best[0]} and #{best[1]} [#{best[2]}]")
            # this one should never fail because its score was positive before
            raise "Unexpected case" unless merge_and_determinize(best[0], best[1])
          end
          
          # blue_fringe does not guarantee that it will not merge a state of lower rank
          # with a kernel state. The kernel should then be update at each step to keep
          # lowest indices for the whole kernel, and we sort it
          @kernel = @kernel.collect{|k| @ufds.find(k)}.sort
        end
        
        # return the refined union find now
        @ufds
      end
      
      #
      # Build the smallest DFA compatible with the sample given as input.
      #
      # Preconditions:
      # - The sample is consistent (does not contains the same string both labeled as
      #   positive and negative) and contains at least one string.
      # 
      # Postconditions:
      # - The returned DFA is the smallest DFA that correctly labels the learning sample
      #   given as input.
      #
      # Remarks:
      # - This instance version of BlueFringe.execute is not intended to be used directly and
      #   is mainly provided for testing purposes. Please use the class variant of this 
      #   method if possible.
      #
      def execute(sample)
        # create union-find
        info("Creating PTA and UnionFind structure")
        ufds = sample2ufds(sample)
        # refine it
        ufds = main(ufds)
        # compute and return quotient automaton
        ufds2dfa(ufds)
      end
      
      #
      # Build the smallest DFA compatible with the sample given as input.
      #
      # Options (the _options_ hash):
      # - :verbose can be set to true to trace algorithm execution on standard output.
      #
      # Preconditions:
      # - The sample is consistent (does not contains the same string both labeled as
      #   positive and negative) and contains at least one string.
      # 
      # Postconditions:
      # - The returned DFA is the smallest DFA that correctly labels the learning sample
      #   given as input.
      #
      def self.execute(sample, options={})
        BlueFringe.new(options).execute(sample)
      end
      
    end # class BlueFringe
    
  end # module Induction
end # module Stamina
