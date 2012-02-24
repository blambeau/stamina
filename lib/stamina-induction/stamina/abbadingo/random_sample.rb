module Stamina
  module Abbadingo
    #
    # Generates a random Sample using the Abbadingo protocol.
    #
    class RandomSample

      #
      # Implements an enumerator for binary strings whose length lies between 0
      # and max_length (passed at construction).
      #
      # The enumerator guarantees that strings are sampled with an uniform
      # distribution among all available. As the number of strings of a given
      # length is an exponential function, this means that you've got 50% change
      # of having a string of length max_length, 25% of max_length - 1, 12.5% of
      # max_length - 2 and so on.
      #
      # How to use it?
      #
      #   # create for strings between 0 and 10 symbols, inclusive
      #   enum = Stamina::Abbadingo::StringEnumerator.new(10)
      #
      #   # this is how to generate strings while a predicate is true
      #   enum.each do |s|
      #     # s is an array of binary integer symbols (0 or 1)
      #     # true for continuing, false otherwise
      #     (true || false)
      #   end
      #
      #   # this is how to generate a fixed number of strings
      #   (1..1000).collect{ enum.one }
      #
      # How does it work? Well, the distribution of strings is as follows:
      #
      #    length     [n]b_strings        [c]umul       log2(n)         log2(c)    log2(c).floor
      #                   (2**n)         2**(n+1)-1
      #      0               1               1       0.0000000000       0.000000        0
      #      1               2               3       1.0000000000       1.584963        1
      #      2               4               7       2.0000000000       2.807355        2
      #      3               8              15       3.0000000000       3.906891        3
      #      4              16              31       4.0000000000       4.954196        4
      #      5              32              63       5.0000000000       5.977280        5
      #
      # where _cumul_ is the total number of string upto _length_ symbols.
      #
      # Therefore, the idea is to see each string has an identifier, say _x_,
      # between 1 and 2**(max_length+1)-1 (see max).
      #   * The length of the _x_th string is log2(x).floor (see length_for)
      #   * The string itself is the binary decomposition of x, up to length_for(x)
      #     symbols (see string_for)
      #
      # As those identifiers naturally respect the exponential distribution, sampling
      # the strings is the same as taking string_for(x) for random x upto _max_.
      #
      class StringEnumerator
        include Enumerable

        # Maximal length of a string
        attr_reader :max_length

        def initialize(max_length = 16)
          @max_length = max_length
        end

        #
        # Returns the length of the string whose identifier is _x_ (> 0)
        #
        def length_for(x)
          Math.log2(x).floor
        end

        #
        # Returns the binary string whose identifier is _x_ (> 0)
        #
        def string_for(x)
          length = length_for(x)
          (0..length-1).collect{|i| ((x >> i) % 2).to_s}
        end

        #
        # Returns the maximum identifier, which is also the number of strings
        # up to max_length symbols
        #
        def max
          @max ||= 2 ** (max_length+1) - 1
        end

        #
        # Generates a string at random
        #
        def one
          string_for(1+Kernel.rand(max))
        end

        #
        # Yields the block with a random string, until the block return false
        # or nil.
        #
        def each
          begin
            cont = yield(one)
          end while cont
        end

      end # class StringEnumerator

      #
      # Generates a Sample instance with _nb_ strings randomly sampled with a
      # uniform distribution over all strings up
      #
      def self.execute(classifier, max_length = classifier.depth + 3)
        enum = StringEnumerator.new(max_length)

        # We generate 1800 strings for the test set plus n^2/2 strings for
        # the training set. If there are no enough strings available, we generate
        # the maximum we can
        seen = {}
        nb = Math.min(1800 + (classifier.state_count**2), enum.max)

        # Let's go now
        enum.each do |s|
          seen[s] = true
          seen.size < nb
        end

        # Make them
        strings = seen.keys.collect{|s| InputString.new(s, classifier.accepts?(s))}
        pos, neg = strings.partition{|s| s.positive?}

        # Split them, 1800 in test and the rest in training set
        if (pos.size > 900) && (neg.size > 900)
          pos_test, pos_training = pos[0...900], pos[900..-1]
          neg_test, neg_training = neg[0...900], neg[900..-1]
        else
          pos_test, pos_training = pos.partition{|s| Kernel.rand < 0.5}
          neg_test, neg_training = neg.partition{|s| Kernel.rand < 0.5}
        end
        flusher = lambda{|x,y| Kernel.rand < 0.5 ? 1 : -1}
        training = (pos_training + neg_training).sort &flusher
        test = (pos_test + neg_test).sort &flusher
        [Sample.new(training), Sample.new(test)]
      end

    end # class RandomSample
  end # module Abbadingo
end # module Stamina