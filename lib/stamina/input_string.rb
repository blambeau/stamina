module Stamina
  #
  # An input string is a sequence of input symbols (symbols being letters appearing 
  # on automaton edges) labeled as positive, negative or unlabeled (provided for test 
  # samples and query strings).
  #
  # This class include the Enumerable module, that allows reasoning about
  # ordered symbols. 
  #
  # == Detailed API
  class InputString
    include Enumerable
  
    #
    # Creates an input string from symbols and positive or negative labeling.
    #
    # Arguments:
    # - symbols: When an array is provided, it is duplicated by default to be kept 
    #   internally. Set dup to false to avoid duplicating it (in both cases, the 
    #   internal array will be freezed). When a String is provided, symbols array 
    #   is created using <tt>symbols.split(' ')</tt> and then freezed. _dup_ is 
    #   ignored in the case.
    # - The positive argument may be true (positive string), false (negative one)
    #   or nil (unlabeled).
    #
    # Raises:
    # - ArgumentError if symbols is not an Array nor a String.
    #
    def initialize(symbols, positive, dup=true)
      raise(ArgumentError,
            "Input string expects an Array or a String: #{symbols} received",
            caller) unless Array===symbols or String===symbols
      @symbols = case symbols
                   when String
                     symbols.split(' ').freeze
                   when Array
                     (dup ? symbols.dup : symbols).freeze
                 end
      @positive = positive
    end
  
    # 
    # Checks if this input string is empty (aka lambda, i.e. contains no symbol). 
    #
    def empty?() @symbols.empty? end
    alias :lambda? :empty?
  
    #
    # Returns the string size, i.e. number of its symbols.
    #
    def size() @symbols.size end
  
    # 
    # Returns the exact label of this string, being true (positive string)
    # false (negative string) or nil (unlabeled)
    #
    def label() @positive end
  
    #
    # Returns true if this input string is positively labeled, false otherwise.
    #
    def positive?() @positive==true end
    
    #
    # Returns true if this input string is negatively labeled, false otherwise.
    #
    def negative?() @positive==false end
    
    #
    # Returns true if this input string unlabeled.
    #
    def unlabeled?() @positive.nil? end
  
    # Copies and returns the same string, but switch the positive flag. This
    # method returns self if it is unlabeled.
    def negate
      return self if unlabeled?
      InputString.new(@symbols, !@positive, false)
    end
  
    #
    # Returns an array with symbols of this string. Returned array may not be 
    # modified (it is freezed).
    #
    def symbols() @symbols end
  
    #
    # Yields the block with each string symbol, in order. Has no effect without
    # block.
    #
    def each() @symbols.each {|s| yield s if block_given? } end

    #
    # Checks equality with another InputString. Returns true if strings have same
    # sequence of symbols and same labeling, false otherwise. Returns nil if _o_ 
    # is not an InputString.
    #
    def ==(o)
      return nil unless InputString===o
      label == o.label and @symbols == o.symbols
    end
    alias :eql? :==
  
    #
    # Computes a hash code for this string.
    #
    def hash
      @symbols.hash + 37*positive?.hash
    end
  
    #
    # Prints this string in ADL.
    #
    def to_adl
      str = (unlabeled? ? '?' : (positive? ? '+ ' : '- '))
      str << @symbols.join(' ')
      str
    end
    alias :to_s :to_adl
    alias :inspect :to_adl
    
  end # class InputString
end # module Stamina