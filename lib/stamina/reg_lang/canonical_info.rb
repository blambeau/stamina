module Stamina
  class RegLang
    class CanonicalInfo
    
      SHORT_PREFIXES = begin
        algo = Stamina::Utils::Decorate.new(:short_prefix)
        algo.set_suppremum do |d0,d1|
          if (d0.nil? || d1.nil?) 
            (d0 || d1)
          else
            d0.size <= d1.size ? d0 : d1
          end
        end
        algo.set_propagate do |deco, edge|
          deco.dup << edge.symbol
        end
        algo
      end

      attr_reader :cdfa
      
      def initialize(lang)
        @cdfa = lang.to_cdfa
      end

      # Returns the short prefix of a state or an edge.
      def short_prefix(s_or_e)
        prefixes!
        s_or_e[:short_prefix] ||= begin
          s_or_e.source[:short_prefix] + [s_or_e.symbol]
        end
      end

      # Returns a positive suffix for `state`
      def positive_suffix(state)
        state[:positive_suffix] ||= find_suffix(state, true)
      end

      # Returns a negative suffix for `state`
      def negative_suffix(state)
        state[:negative_suffix] ||= find_suffix(state, false)
      end

      #
      # Returns the short prefixes of the language as a sample
      #
      def short_prefixes
        prefixes = Sample.new
        cdfa.each_state do |s|
          prefixes << InputString.new(short_prefix(s), s.accepting?)
        end
        prefixes
      end

      #
      # Returns the language kernel as a sample
      #
      def kernel
        kernel = Sample.new
        kernel << InputString.new([], cdfa.initial_state.accepting?)
        cdfa.each_edge do |e|
          kernel << InputString.new(short_prefix(e), e.target.accepting?)
        end
        kernel
      end

      #
      # Builds a characteristic sample 
      #
      def characteristic_sample
        sample = Sample.new

        # at least one positive string should be found from
        # the initial state
        if pos = positive_suffix(cdfa.initial_state)
          sample << InputString.new(pos, true)
        else
          sample << InputString.new([], false)
          return sample
        end
        
        # condition 1: positive string for each element of the kernel 
        cdfa.each_edge do |edge|
          pos = short_prefix(edge) + positive_suffix(edge.target)
          sample << InputString.new(pos, true, false)
        end

        # condition 2: pair-wise distinguising suffixes
        cdfa.each_state do |source|
          cdfa.each_edge do |edge|
            next if (target = edge.target) == source
            if suffix = distinguish(source, target)
              sign = cdfa.accepts?(suffix, source)
              sample << InputString.new(short_prefix(source) + suffix, sign)
              sample << InputString.new(short_prefix(edge) + suffix, !sign)
            end
          end
        end

        sample
      end

      private

      # Ensures that short prefixes of states are recognized
      def prefixes!
        unless defined?(@prefixes)
          SHORT_PREFIXES.execute(cdfa, nil, [])
          @prefixes = true
        end
      end

      def cross(xs, ys)
        xs.each{|x| ys.each{|y| yield(x,y)}}
      end

      # Distinguishes two states, returning a suffix which is accepted for one
      # and rejected by the other
      def distinguish(x, y)
        raise ArgumentError, "x and y should be different" if x == y
        build_distinguish_matrix[[x,y].sort]
      end

      def build_distinguish_matrix
        @diff_matrix ||= begin
          mat = {}

          # pairs to be explored
          to_explore = [] 

          # start by marking accepting vs. non-accepting states
          acc, nonacc = cdfa.states.partition{|s| s.accepting?}
          cross(acc, nonacc) do |*pair|
            mat[pair.sort!] = []
            to_explore << pair
          end

          # Visit each pair backwards
          while pair = to_explore.pop
            suffix = mat[pair]
            cross(pair[0].in_edges, pair[1].in_edges) do |se, te|
              next if se.symbol != te.symbol
              source = [se.source, te.source].sort!
              if mat[source].nil? || 
                 (mat[source].length > (1+suffix.length))
                mat[source] = [se.symbol] + suffix
                to_explore.push(source)
              end
            end
          end

          mat
        end
      end

      # Recursively finds a positive/negative suffix for `state`
      def find_suffix(state, positive, stack = [], seen = {})
        if positive == state.accepting?
          # (pos and accepting) or (neg and non-accepting) => lambda
          stack
        elsif found = state.out_edges.find{|e| positive == e.target.accepting?}
          # at one step => augment stack with symbol
          stack << found.symbol
        elsif found = state.out_edges.find{|e| !seen.has_key?(e.target)}
          # recurse on a neighbour if you find one
          seen[state] = true
          find_suffix(found.target, positive, stack << found.symbol, seen)
        elsif !positive
          # in case of negative suffix: pick one in alphabet
          outs  = state.out_symbols
          found = state.automaton.alphabet.find{|s| !outs.include?(s)}
          found ? (stack << found) : nil
        else
          # unable to find a suffix :-(
          nil
        end
      end

    end # class CanonicalInfo
  end # class RegLang
end # module Stamina
