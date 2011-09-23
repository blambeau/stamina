module Stamina
  class RegLang
    
    module ShortPrefix
      def suppremum(d0, d1) 
        return d0 if d1.nil?
        return d1 if d0.nil?
        d0.size <= d1.size ? d0 : d1
      end
      def propagate(deco, edge) 
        deco.dup << edge.symbol
      end
    end

    #
    # Returns the language kernel as a sample
    #
    def kernel
      algo = Stamina::Utils::Decorate.new(:short_prefix)
      algo.extend(ShortPrefix)
      algo.execute(cdfa = to_cdfa, nil, [])
      kernel = Sample.new
      kernel << InputString.new([], cdfa.initial_state.accepting?)
      cdfa.each_edge do |edge|
        symbols  = edge.source[:short_prefix] + [edge.symbol]
        positive = edge.target.accepting?
        kernel << InputString.new(symbols, positive, false)
      end
      kernel
    end

  end # class RegLang
end # module Stamina
