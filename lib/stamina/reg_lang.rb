module Stamina
  class RegLang
    require "stamina/reg_lang/node"
    require "stamina/reg_lang/parenthesized"
    require "stamina/reg_lang/symbol"
    require "stamina/reg_lang/question"
    require "stamina/reg_lang/plus"
    require "stamina/reg_lang/star"
    require "stamina/reg_lang/sequence"
    require "stamina/reg_lang/alternative"
    Citrus.require "stamina/reg_lang/parser"

    # Automaton capturing this regular language
    attr_reader :fa

    #
    # Creates a regular language instance based on an automaton.
    #
    def initialize(fa)
      @fa = fa
    end

    # 
    # Creates a regular language by parsing an expression.
    #
    def self.parse(str)
      RegLang.new(Parser.parse(str).to_fa)
    end

    #
    # Returns the prefix-closed version of this regular language.
    #
    def prefix_closed
      automaton = fa.dup
      automaton.each_state{|s| s.accepting!}
      RegLang.new(automaton)
    end

    #
    # Returns the complement of this regular language
    #
    def complement
      RegLang.new(to_dfa.complement)
    end

    #
    # Returns a regular language defined as the union of `self` with `other`.
    #
    def +(other)
      unioned = Automaton.new
      fa.dup(unioned)
      other.to_fa.dup(unioned)
      RegLang.new(unioned)
    end

    # 
    # Checks if this regular language includes a given string
    #
    def include?(str)
      fa.accepts?(str)
    end

    #
    # Returns a finite automaton capturing this regular language.
    #
    # Returned automaton may be non-deterministic.
    #
    def to_fa
      fa.dup
    end

    #
    # Returns a deterministic finite automaton capturing this regular 
    # language.
    #
    # Returned automaton is not guaranteed to be minimal or canonical.
    #
    def to_dfa
      fa.determinize
    end

    #
    # Returns the canonical deterministic finite automaton capturing this
    # regular language.
    #
    def to_cdfa
      fa.to_cdfa
    end

    #
    # Checks if `self` and `other` capture the same regular language.
    #
    def eql?(other)
      self.to_cdfa <=> other.to_cdfa
    end

    protected :fa
  end # class RegLang
end # module Stamina
