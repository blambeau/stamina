module Stamina

  #
  # A sample as an ordered collection of InputString labeled as positive or negative.
  #
  # == Tips and tricks
  # - loading samples from disk is easy thanks to ADL !
  #
  # == Detailed API
  class Sample
    include Enumerable

    # Number of strings in the sample
    attr_reader :size

    # Number of positive strings in the sample
    attr_reader :positive_count

    # Number of negative strings in the sample
    attr_reader :negative_count

    #
    # Creates an empty sample and appends it with args, by calling Sample#<< on
    # each of them.
    #
    def self.[](*args) Sample.new << args end

    #
    # Creates an empty sample.
    #
    def initialize(strings = nil)
      @strings = []
      @size, @positive_count, @negative_count = 0, 0, 0
      strings.each{|s| self << s } unless strings.nil?
    end

    #
    # Coerces `arg` to a Sample instance.
    #
    def self.coerce(arg)
      if arg.is_a?(Sample)
        arg
      elsif arg.is_a?(String)
        parse(arg)
      else
        raise ArgumentError, "Invalid argument #{arg} for `Sample`"
      end
    end

    #
    # Parses an ADL input
    #
    def self.parse(adl)
      ADL::parse_sample(adl)
    end

    #
    # Returns true if this sample does not contain any string,
    # false otherwise.
    #
    def empty?()
      @size==0
    end

    #
    # Adds a string to the sample. The _str_ argument may be an InputString instance,
    # a String (parsed using ADL), a Sample instance (all strings are added) or an
    # Array (recurses on each element).
    #
    # Raises an InconsistencyError if the same string already exists with the
    # opposite label. Raises an ArgumentError if the _str_ argument is not recognized.
    #
    def <<(str)
      case str
        when InputString
          #raise(InconsistencyError, "Inconsistent sample on #{str}", caller) if self.include?(str.negate)
          @size += 1
          str.positive? ? (@positive_count += 1) : (@negative_count += 1)
          @strings << str
        when String
          self << ADL::parse_string(str)
        when Sample
          str.each {|s| self << s}
        when Array
          str.each {|s| self << s}
        else
          raise(ArgumentError, "#{str} is not a valid argument.", caller)
      end
      self
    end

    #
    # Returns true if a given string is included in the sample, false otherwise.
    # This method allows same flexibility as << for the _str_ argument.
    #
    def include?(str)
      case str
        when InputString
          @strings.include?(str)
        when String
          include?(ADL::parse_string(str))
        when Array
          str.each {|s| return false unless include?(s)}
          true
        when Sample
          str.each {|s| return false unless include?(s)}
          true
        else
          raise(ArgumentError, "#{str} is not a valid argument.", caller)
      end
    end

    #
    # Returns a new sample as the union of both `self` and `other`
    #
    def +(other)
      s = Sample.new
      each{|x| s << x}
      other.each{|x| s << x}
      s
    end

    #
    # Compares with another sample _other_, which is required to be a Sample
    # instance. Returns true if the two samples contains the same strings (including
    # labels), false otherwise.
    #
    def ==(other)
      include?(other) and other.include?(self)
    end
    alias :eql? :==

    #
    # Computes an hash code for this sample.
    #
    def hash
      self.inject(37){|memo,str| memo + 17*str.hash}
    end

    #
    # Yields the block with each string. This method has no effect if no
    # block is given.
    #
    def each
      return unless block_given?
      @strings.each {|str| yield str}
    end

    #
    # Yields the block with each positive string. This method has no effect if no
    # block is given.
    #
    def each_positive
      return unless block_given?
      each {|str| yield str if str.positive?}
    end

    #
    # Returns an enumerator on positive strings.
    #
    def positive_enumerator
		  if RUBY_VERSION >= "1.9"
        Enumerator.new(self, :each_positive)
      else
        Enumerable::Enumerator.new(self, :each_positive)
			end
    end

    #
    # Yields the block with each negative string. This method has no effect if no
    # block is given.
    #
    def each_negative
      each {|str| yield str if str.negative?}
    end

    #
    # Returns an enumerator on negative strings.
    #
    def negative_enumerator
		  if RUBY_VERSION >= "1.9"
        Enumerator.new(self, :each_negative)
      else
        Enumerable::Enumerator.new(self, :each_negative)
			end
    end

    #
    # Checks if the sample is correctly classified by a given classifier
    # (expected to include the Stamina::Classfier module).
    # Unlabeled strings are simply ignored.
    #
    def correctly_classified_by?(classifier)
      classifier.correctly_classify?(self)
    end

    #
    # Computes and returns the binary signature of the sample. The signature
    # is a String having one character for each string in the sample. A '1'
    # is used for positive strings, '0' for negative ones and '?' for unlabeled.
    #
    def signature
      signature = ''
      each do |str|
        signature << (str.unlabeled? ? '?' : str.positive? ? '1' : '0')
      end
      signature
    end

    #
    # Takes only a given proportion of this sample and returns it as a new Sample.
    #
    def take(proportion = 0.5)
      taken = Stamina::Sample.new
      each_positive{|s| taken << s if Kernel.rand < proportion}
      each_negative{|s| taken << s if Kernel.rand < proportion}
      taken
    end

    #
    # Prints an ADL description of this sample on the buffer.
    #
    def to_adl(buffer="")
      self.inject(buffer) {|memo,str| memo << "\n" << str.to_adl}
    end
    alias :to_s :to_adl
    alias :inspect :to_adl

    #
    # Converts a Sample to an (augmented) prefix tree acceptor. This method ensures
    # that the states of the PTA are in lexical order, according to the <code><=></code>
    # operator defined on symbols. States reached by negative strings are tagged as
    # non accepting and error.
    #
    def self.to_pta(sample)
      thepta = Automaton.new do |pta|
        initial_state = add_state(:initial => true, :accepting => false)

        # Fill the PTA with each string
        sample.each do |str|
          # split string using the dfa
          parsed, reached, remaining = pta.dfa_split(str, initial_state)

          # remaining symbols are not empty -> build the PTA
          unless remaining.empty?
            remaining.each do |symbol|
              newone = pta.add_state(:initial => false, :accepting => false, :error => false)
              pta.connect(reached, newone, symbol)
              reached = newone
            end
          end

          # flag state
          str.positive? ? reached.accepting! : reached.error!

          # check consistency, should not arrive as Sample does not allow
          # inconsistencies. Should appear only if _sample_ is not a Sample
          # instance but some other enumerable.
          raise(InconsistencyError, "Inconsistent sample on #{str}", caller)\
            if (reached.error? and reached.accepting?)
        end

        # Reindex states by applying BFS
        to_index, index = [initial_state], 0
        until to_index.empty?
          state = to_index.shift
          state[:__index__] = index
          state.out_edges.sort{|e,f| e.symbol<=>f.symbol}.each{|e| to_index << e.target}
          index += 1
        end
      end

      # Now we rebuild a fresh one with states in order.
      # This look more efficient that reordering states of the PTA
      Automaton.new do |ordered|
        ordered.add_n_states(thepta.state_count)
        thepta.each_state do |pta_state|
          source = ordered.ith_state(pta_state[:__index__])
          source.initial!   if pta_state.initial?
          source.accepting! if pta_state.accepting?
          source.error!     if pta_state.error?
          pta_state.out_edges.each do |e|
            target = ordered.ith_state(e.target[:__index__])
            ordered.connect(source, target, e.symbol)
          end
        end
      end

    end

    # Converts this sample to a PTA
    def to_pta
      Sample.to_pta(self)
    end
    alias :to_fa  :to_pta
    alias :to_dfa :to_pta

    # Converts this sample to a canonical dfa
    def to_cdfa
      to_pta.to_cdfa
    end

    # Converts this sample to a dot output
    def to_dot
      to_pta.to_dot
    end

  end # class Sample
end # module Stamina