module Stamina
  class RegLang
    
    #
    # Returns the short prefixes of the language as a sample
    #
    def short_prefixes
      cdfa = SHORT_PREFIXES_EXTRACTOR.execute(to_cdfa, nil, [])
      prefixes = Sample.new
      cdfa.each_state do |s|
        prefixes << InputString.new(s[:short_prefix], s.accepting?, false)
      end
      prefixes
    end

    #
    # Returns the language kernel as a sample
    #
    def kernel
      cdfa = SHORT_PREFIXES_EXTRACTOR.execute(to_cdfa, nil, [])
      kernel = Sample.new
      kernel << InputString.new([], cdfa.initial_state.accepting?)
      cdfa.each_edge do |edge|
        symbols  = edge.source[:short_prefix] + [edge.symbol]
        positive = edge.target.accepting?
        kernel << InputString.new(symbols, positive, false)
      end
      kernel
    end

    private 

    SHORT_PREFIXES_EXTRACTOR = begin
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

  end # class RegLang
end # module Stamina
