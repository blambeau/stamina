module Stamina
  module Utils
    #
    # Decorates states of an automaton by applying a propagation rule
    # until a fix point is reached.
    #
    class Decorate

      # The key to use to maintain the decoration on states (:invariant
      # is used by default)
      attr_writer :decoration_key

      # Creates a decoration algorithm instance
      def initialize(decoration_key = :invariant)
        @decoration_key = decoration_key
        @suppremum = nil
        @propagate = nil
        @initiator = nil
        @start_predicate = nil
        @backward = false
      end

      # Installs a suppremum function through a block.
      def set_suppremum(&block)
        raise ArgumentError, 'Suppremum expected through a block' if block.nil?
        raise ArgumentError, 'Block of arity 2 expected' unless block.arity==2
        @suppremum = block
      end

      # Same as #set_suppremum, but with an explicit proc
      def suppremum=(proc)
        set_suppremum(&proc)
      end

      # Computes the suppremum between two decorations. By default, this method
      # looks for a suppremum function installed with set_suppremum. If not found,
      # it tries calling a suppremum method on d0. If not found it raises an error.
      # This method may be overriden.
      def suppremum(d0, d1)
        return @suppremum.call(d0, d1) if @suppremum
        return d0.suppremum(d1) if d0.respond_to?(:suppremum)
        raise "No suppremum function installed or implemented by decorations"
      end

      # Installs a propagate function through a block.
      def set_propagate(&block)
        raise ArgumentError, 'Propagate expected through a block' if block.nil?
        raise ArgumentError, 'Block of arity 2 expected' unless block.arity==2
        @propagate = block
      end

      # Same as #set_propagate, but with an explicit proc
      def propagate=(proc)
        set_propagate(&proc)
      end

      # Computes the propagation rule. By default, this method looks for a propagate
      # function installed with set_propagate. If not found, it tries calling a +
      # method on deco. If not found it raises an error.
      # This method may be overriden.
      def propagate(deco, edge)
        return @propagate.call(deco, edge) if @propagate
        return deco.+(edge) if deco.respond_to?(:+)
        raise "No propagate function installed or implemented by decorations"
      end

      # Set an initiator methods, responsible of computing the initial decoration of
      # each state
      def set_initiator(&block)
        raise ArgumentError, 'Initiator expected through a block' if block.nil?
        raise ArgumentError, 'Block of arity 1 expected' unless block.arity==1
        @initiator = block
      end

      # Same as #set_initiator but with an explicit proc
      def initiator=(proc)
        set_initiator(&proc)
      end

      # Returns the initial decoration of state `s`
      def init_deco(s)
        return @initiator.call(s) if @initiator
        raise "No initiator function installed"
      end

      # Sets the start predicate to use
      def set_start_predicate(&block)
        raise ArgumentError, 'Start predicate expected through a block' if block.nil?
        raise ArgumentError, 'Block of arity 1 expected' unless block.arity==1
        @start_predicate = block
      end

      # Same as #set_start_predicate but with an explicit proc
      def start_predicate=(proc)
        set_start_predicate(&proc)
      end

      # Returns the start predicate
      def take_at_start?(s)
        return @start_predicate.call(s) if @start_predicate
        raise "No start predicate function installed"
      end

      # Sets if the algorithms works backward
      def backward=(val)
        @backward = val
      end

      # Work backward?
      def backward?
        @backward
      end

      # Executes the propagation algorithm on a given automaton.
      def call(fa)
        fa.states.each do |s|
          s[@decoration_key] = init_deco(s)
        end
        to_explore = fa.states.select{|s| take_at_start?(s)}
        until to_explore.empty?
          source = to_explore.pop
          (backward? ? source.in_edges : source.out_edges).each do |edge|
            target = backward? ? edge.source : edge.target
            p_decor = propagate(source[@decoration_key], edge)
            p_decor = suppremum(target[@decoration_key], p_decor)
            unless p_decor == target[@decoration_key]
              target[@decoration_key] = p_decor
              to_explore << target unless to_explore.include?(target)
            end
          end
        end
        fa
      end

      # Executes the propagation algorithm on a given automaton.
      def execute(fa, bottom, d0)
        self.initiator       = lambda{|s| (s.initial? ? d0 : bottom)}
        self.start_predicate = lambda{|s| s.initial? }
        call(fa)
      end

    end # class Decorate
  end # module Utils
end # module Stamina