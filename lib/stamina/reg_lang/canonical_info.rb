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

      # Returns the short prefix of `state`
      def short_prefix(state)
        SHORT_PREFIXES.execute(cdfa, nil, []) unless state[:short_prefix]
        state[:short_prefix]
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
        cdfa.each_edge do |edge|
          symbols  = short_prefix(edge.source) + [edge.symbol]
          positive = edge.target.accepting?
          kernel << InputString.new(symbols, positive, false)
        end
        kernel
      end

      private

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
        elsif !positive && 
              (found = (state.automaton.alphabet.to_a - state.out_symbols).first)
          # in case of negative suffix: pick one in alphabet
          stack << found
        else
          # unable to find a suffix :-(
          nil
        end
      end

    end # class CanonicalInfo
  end # class RegLang
end # module Stamina
