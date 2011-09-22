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
    require "stamina/reg_lang/regexp"
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
    # Builds a sigma star language
    # 
    def self.sigma_star(alph)
      new(Automaton.new do |fa|
        fa.alphabet = alph.to_a
        fa.add_state(:initial => true, :accepting => true)
        alph.each do |symbol|
          fa.connect(0,0,symbol)
        end
      end)
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

    def **(x)
      raise ArgumentError, "Invalid argument for ** (#{x})" unless x == -1
      complement
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
    alias :| :+
    alias :union :+

    #
    # Returns a regular language defined as the intersection of `self` with 
    # `other`.
    #
    def *(other)
      RegLang.new(fa.compose(other.fa))
    end
    alias :& :*
    alias :intersection :*

    #
    # Returns a regular language defined capturing all strings from `self` but
    # those in common with `other`.
    #
    def -(other)
      self & other.complement
    end
    alias :difference :-

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
    # Returns a dot output
    # 
    def to_dot
      dfa = to_cdfa
      dfa.depth
      dfa.order_states{|s,t| s[:depth] <=> t[:depth]}
      dfa.to_dot
    end

    #
    # Checks if `self` and `other` capture the same regular language.
    #
    def eql?(other)
      self.to_cdfa <=> other.to_cdfa
    end
    alias :<=> :eql?

    protected :fa
  end # class RegLang
end # module Stamina
