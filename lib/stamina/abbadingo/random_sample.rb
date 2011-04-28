module Stamina
  module Abbadingo
    #
    # Generates a random Sample using the Abbadingo protocol.
    # 
    class RandomSample

      # Size of the target classifier
      attr_reader :dfa_size

      # Creates an algorithm instance with default options
      def initialize(dfa_size = 64)
        @dfa_size = dfa_size
      end

      # Returns the maximal number of a string
      def max_string_length
        @max_string_length ||= (2 * Math.log2(dfa_size) + 3).ceil
      end

      # Returns the number of strings up to max_string_length
      def string_count
        # Exactly the same as 16 * (dfa_size ** 2) -1
        @string_count ||= (2 ** (max_string_length + 1)) - 1;
      end

      #
      # Returns the length of the string whose identifier is _x_
      #
      def length_for(x)
        sum = 0
        (0..max_string_length).each do |length|
          sum += 2 ** length
          return length if sum >= x
        end
        max_string_length
      end

      # Generates a single string
      def generate_string
        y = Kernel.rand(string_count)
        length = length_for(1 + y)
        s = ""
        length.times{ s << Kernel.rand(2).to_s }
        s
      end

      # Generates a full sample of _size_ strings, without replacement
      def generate_sample(classifier, size = dfa_size ** 2)
        s, seen = Stamina::Sample.new, {}
        until s.size == size 
          string = generate_string
          next if seen[string]
          if classifier.label_of(string) == 0
            s << "- #{string}"
          else
            s << "+ #{string}"
          end
        end
      end

    end # class RandomSample
  end # module Abbadingo
end # module Stamina

