module Stamina
  module Induction
    
    #
    # Implementation of the standard Regular Positive and Negative Induction (RPNI) 
    # algorithm. From a given sample, containing positive and negative strings, RPNI
    # computes the smallest deterministic automaton compatible with the sample.
    #
    # See J. Oncina and P. Garcia, Infering Regular Languages in Polynomial Update
    # Time, In N. Perez de la Blanca, A. Sanfeliu and E. Vidal, editors, Pattern
    # Recognition and Image Analysis, volume 1 of Series in Machines Perception and
    # Artificial Intelligence, pages 49-61, World Scientific, 1992.
    #
    # Example:
    #   # sample typically comes from an ADL file
    #   sample = Stamina::ADL.parse_sample_file('sample.adl')
    #
    #   # let RPNI build the smallest dfa
    #   dfa = Stamina::Induction::RPNI.execute(sample, {:verbose => true})
    #
    # Remarks:
    # - Constructor and instance methods of this class are public but not intended 
    #   to be used directly. They are left public for testing purposes only.
    # - This class intensively uses the Stamina::Induction::UnionFind class and 
    #   methods defined in the Stamina::Induction::Commons module which are worth
    #   reading to understand the algorithm implementation.
    #
    class RPNI
      include Stamina::Induction::Commons
      
      # Union-find data structure used internally
      attr_reader :ufds
      
      #
      # Merges a state of rank j with a state of lower rank i. This merge method 
      # includes merging for determinization.
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
      #   this method returns true and the refined union-find correctly encodes the 
      #   quotient automaton. Otherwise, the method returns false and the union-find
      #   information must be considered inaccurate.
      #
      def merge_and_determinize(i, j)
        # Make the union (keep additional merges to be performed in determinization)
        # and recompute the user data attached to the new state group (new_data)
        determinization = []
        @ufds.union(i, j) do |d1, d2|
          new_data = merge_user_data(d1, d2, determinization)
          return false unless new_data
          new_data
        end
        
        # Merge for determinization
        determinization.each do |pair|
          # we take the leader states of the pair to merge
          pair = pair.collect{|i| @ufds.find(i)}
          # do nothing if already the same leader state
          next if pair[0]==pair[1]
          # otherwise recurse or fail
          return false unless merge_and_determinize(pair[0], pair[1]) 
        end
        
        # Everything seems ok!
        true
      end
      
      #
      # Makes a complete merge (including determinization), or simply do nothing if 
      # it leads accepting a negative string.
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
      #   this method returns true and the refined union-find correctly encodes the 
      #   quotient automaton. Otherwise, the union find has not been changed.
      #
      def successfull_merge_or_nothing(i,j)
        # try a merge and determinize inside a transaction on the ufds
        @ufds.transactional do
          merge_and_determinize(i, j)
        end
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
        @ufds = ufds
        info("Starting RPNI (#{@ufds.size} states)")
        # First loop, iterating all PTA states
        (1...@ufds.size).each do |i|
          # we ignore those that have been previously merged
          next if @ufds.slave?(i) 
          # second loop: states of lower rank, with ignore
          (0...i).each do |j|
            next if @ufds.slave?(j)
            # try to merge this pair, including determinization
            # simply break the loop if it works!
            success = successfull_merge_or_nothing(i,j)
            if success
              info("#{i} and #{j} successfully merged")
              break
            end
          end # j loop
        end # i loop
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
      # - This instance version of RPNI.execute is not intended to be used directly and
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
        RPNI.new(options).execute(sample)
      end
      
    end # class RPNI
    
  end # module Induction
end # module Stamina
