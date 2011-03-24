module Stamina
  #
  # Provides a reusable module for binary classifiers. Classes including this
  # module are required to provide a label_of(string) method, returning '1' for
  # strings considered positive, and '0' fr strings considered negative.
  #
  # Note that an Automaton being a classifier it already includes this module.
  #
  module Classifier
    
    #
    # Computes a signature for a given sample (that is, an ordered set of strings).
    # The signature is a string containing 1 (considered positive, or accepted) 
    # and 0 (considered negative, or rejected), one for each string.
    #
    def signature(sample)
      signature = ''
      sample.each do |str|
        signature << label_of(str)
      end
      signature
    end
    alias :classification_signature :signature

    #
    # Classifies a sample then compute the classification scoring that is obtained
    # by comparing the signature obtained by classification and the one of the sample
    # itself. Returns an object responding to methods defined in Scoring module.
    #
    # This method is actually a convenient shortcut for:
    #
    #    Stamina::Scoring.scoring(signature(sample), sample.signature)
    #
    def scoring(sample)
      Stamina::Scoring.scoring(signature(sample), sample.signature)
    end
    alias :classification_scoring :scoring
    
    # 
    # Checks if a labeled sample is correctly classified by the classifier.
    #
    def correctly_classify?(sample)
      sample.each do |str|
        label = label_of(str)
        expected = (str.positive? ? '1' : '0')
        return false unless expected==label
      end
      true
    end
    
  end # module Classifier
end # module Stamina
