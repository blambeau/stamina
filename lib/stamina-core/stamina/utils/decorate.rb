module Stamina
  module Utils
    #
    # Decorates states of an automaton by applying a propagation rule until a fix point is
    # reached.
    #
    class Decorate

      # Creates a decoration algorithm instance
      def initialize(output = :invariant)
        @output    = Decorate.state_output(output) if output
        @suppremum = nil
        @propagate = nil
        @initiator = nil
        @backward  = false
        @start_predicate = nil
      end

      # Builds an output hash that keeps decoration in states
      def self.state_output(decoration_key)
        Object.new.extend Module.new{
          define_method :[] do |state|
            state[decoration_key]
          end
          define_method :[]= do |state,deco|
            state[decoration_key] = deco
          end
        }
      end

      ### CONFIGURATION ##################################################################

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

      # Sets if the algorithms works backward
      def backward=(val)
        @backward = val
      end

      ### SUBCLASS HOOKS #################################################################

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

      # Returns the initial decoration of state `s`
      def init_deco(s)
        return @initiator.call(s) if @initiator
        raise "No initiator function installed"
      end

      # Returns the start predicate
      def take_at_start?(s)
        return @start_predicate.call(s) if @start_predicate
        raise "No start predicate function installed"
      end

      # Work backward?
      def backward?
        @backward
      end

      ### MAIN ###########################################################################

      # Executes the propagation algorithm on a given automaton.
      def call(fa, out = nil)
        with_output(out) do |output|
          fa.states.each{|s| output[s] = init_deco(s) }        # Init decoration on each state
          to_explore = fa.states.select{|s| take_at_start?(s)} # Init to_explore (start predicate)
          until to_explore.empty?                              # empty to_explore now
            source = to_explore.pop
            each_edge_and_target(source) do |edge, target|
              p_decor = propagate(output[source], edge)
              p_decor = suppremum(output[target], p_decor)
              unless p_decor == output[target]
                output[target] = p_decor
                to_explore << target unless to_explore.include?(target)
              end
            end
          end
          fa
        end
      end

      # Executes the propagation algorithm on a given automaton.
      def execute(fa, bottom, d0)
        warn "Decorate#execute is deprecated, use Decorate#call (#{caller[0]})"
        self.initiator       = lambda{|s| (s.initial? ? d0 : bottom)}
        self.start_predicate = lambda{|s| s.initial? }
        call(fa)
      end

    private

      def with_output(out)
        if out
          yield out.is_a?(Symbol) ? Decorate.state_output(out) : out
        elsif @output
          warn "Decorate.new(:decokey) is deprecated, use Decorate#call(fa, :decokey) (#{caller[1]})"
          yield @output
        else
          raise ArgumentError, "Output may not be nil", caller
        end
      end

      def each_edge_and_target(source)
        edges = backward? ? source.in_edges : source.out_edges
        edges.each do |edge|
          target = target = backward? ? edge.source : edge.target
          yield edge, target
        end
      end

    end # class Decorate
  end # module Utils
end # module Stamina