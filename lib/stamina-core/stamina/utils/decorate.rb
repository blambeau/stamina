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
      end

      # Installs a suppremum function through a block.
      def set_suppremum(&block)
        raise ArgumentError, 'Suppremum expected through a block' if block.nil?
        raise ArgumentError, 'Block of arity 2 expected' unless block.arity==2
        @suppremum = block
      end

      # Installs a propagate function through a block.
      def set_propagate(&block)
        raise ArgumentError, 'Propagate expected through a block' if block.nil?
        raise ArgumentError, 'Block of arity 2 expected' unless block.arity==2
        @propagate = block
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

      # Computes the propagation rule. By default, this method looks for a propagate
      # function installed with set_propagate. If not found, it tries calling a +
      # method on deco. If not found it raises an error.
      # This method may be overriden.
      def propagate(deco, edge)
        return @propagate.call(deco, edge) if @propagate
        return deco.+(edge) if deco.respond_to?(:+)
        raise "No propagate function installed or implemented by decorations"
      end

      # Executes the propagation algorithm on a given automaton.
      def execute(fa, bottom, d0)
        to_explore = []

        # install initial decoration
        fa.states.each do |s|
          s[@decoration_key] = (s.initial? ? d0 : bottom)
          to_explore << s if s.initial?
        end

        # fix-point loop starting with initial states
        until to_explore.empty?
          source = to_explore.pop
          source.out_edges.each do |edge|
            target = edge.target
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

    end # class Decorate
  end # module Utils
end # module Stamina