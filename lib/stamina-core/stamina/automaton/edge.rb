module Stamina
  class Automaton
    #
    # Automaton edge.
    #
    class Edge
      include Stamina::Markable
      attr_reader :automaton, :index, :from, :to

      #
      # Creates an edge.
      #
      # Arguments:
      # - automaton: parent automaton of the edge.
      # - index: index of the edge in the edge list.
      # - data: user data attached to this edge.
      # - from: source state of the edge.
      # - to: target state of the edge.
      #
      def initialize(automaton, index, data, from, to)
        @automaton, @index = automaton, index
        @data = data
        @from, @to = from, to
      end

      # Returns edge symbol.
      def symbol()
        @data[:symbol]
      end

      # Sets edge symbol.
      def symbol=(symbol)
        @data[:symbol] = symbol
      end

      alias :source :from
      alias :target :to

      #
      # Provides comparator of edges, based on the index in the automaton edge
      # list. This method returns nil unless  _o_ is an Edge from the same
      # automaton than self.
      # Once again, this method has nothing to do with equality, it looks at an
      # index and ID only.
      #
      def <=>(o)
        return nil unless Edge===o
        return nil unless automaton===o.automaton
        return index <=> o.index
      end

      # Returns a string representation
      def inspect
        'e' << @index.to_s
      end

      # Returns a string representation
      def to_s
        'e' << @index.to_s
      end

      ### protected write section ################################################
      protected

      # Changes the index of this edge in the edge list. This method is only
      # expected to be used by the automaton itself.
      def index=(i) @index=i end

      #
      # Fired by Loaded when a user data is changed. The message if forwarded to
      # the automaton.
      #
      def state_changed(what, infos)
        @automaton.send(:state_changed, what, infos)
      end

    end # class Edge
  end # class Automaton
end # module Stamina