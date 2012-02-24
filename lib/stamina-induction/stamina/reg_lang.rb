require_relative "reg_lang/parser"
module Stamina
  class RegLang

    # Automaton capturing this regular language
    attr_reader :fa
    protected :fa

    #
    # Creates a regular language instance based on an automaton.
    #
    def initialize(fa)
      @fa = fa
    end

    ############################################################################
    # CLASS METHODS

    #
    # Coerces `arg` to a regular language
    #
    # @raise ArgumentError if `arg` cannot be coerced to a regular language
    #
    def self.coerce(arg)
      if arg.respond_to?(:to_reglang)
        arg.to_reglang
      elsif arg.respond_to?(:to_fa)
        new(arg.to_fa)
      elsif arg.is_a?(String)
        parse(arg)
      else
        raise ArgumentError, "Invalid argument #{arg} for `RegLang`"
      end
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

    ############################################################################
    # OPERATORS

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
    # Returns the regular language defined when abstracting from `symbols`
    #
    def hide(symbols)
      RegLang.new(fa.hide(symbols))
    end

    #
    # Returns the regular language defined when projecting on `symbols`
    #
    def project(symbols)
      RegLang.new(fa.keep(symbols))
    end

    ############################################################################
    # CANONICAL DFA

    def short_prefixes
      canonical_info.short_prefixes
    end

    def kernel
      canonical_info.kernel
    end

    def characteristic_sample
      canonical_info.characteristic_sample
    end

    private

    def canonical_info
      @canonical_info ||= CanonicalInfo.new(self)
    end

    ############################################################################
    # QUERIES
    public

    #
    # Checks if the language is empty
    #
    def empty?
      self <=> EMPTY
    end

    #
    # Checks if this regular language includes a given string
    #
    def include?(str)
      fa.accepts?(str)
    end

    #
    # Checks if `self` and `other` capture the same regular language.
    #
    def eql?(other)
      self.to_cdfa <=> other.to_cdfa
    end
    alias :<=> :eql?

    ############################################################################
    # COERCIONS

    #
    # Returns self.
    #
    def to_reglang
      self
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

    EMPTY = RegLang.new(Automaton::DUM)
  end # class RegLang
end # module Stamina
require_relative 'reg_lang/canonical_info'