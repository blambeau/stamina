module Stamina
  #
  # Provides utility methods for scoring binary classifiers from signatures
  #
  module Scoring

      #
      # From the signatures of a learned model and a actual, returns an object
      # responding to all instance methods defined in the Scoring module.
      #
      def self.scoring(learned, actual, max_size=nil)
        unless learned.size==actual.size
          raise ArgumentError, "Signatures must be of same size (#{learned.size} vs. #{actual.size})"
        end
        max_size ||= learned.size
        max_size = learned.size if max_size > learned.size
        tp, fn, fp, tn = 0, 0, 0, 0
        (0...max_size).each do |i|
          positive, labeled_as = actual[i..i]=='1', learned[i..i]=='1'
          if positive==labeled_as
            positive ? (tp += 1) : (tn += 1)
          else
            positive ? (fn += 1) : (fp += 1)
          end
        end
        measures = { :true_positive  => tp,
                     :true_negative  => tn,
                     :false_positive => fp,
                     :false_negative => fn }
        measures.extend(Scoring)
        measures
      end

      #
      # Returns the number of positive strings correctly labeled as positive
      #
      def true_positive
        self[:true_positive]
      end

      #
      # Returns the number of negative strings correctly labeled as negative.
      #
      def true_negative
        self[:true_negative]
      end

      #
      # Returns the number of negative strings incorrectly labeled as positive.
      #
      def false_positive
        self[:false_positive]
      end

      #
      # Returns the number of positive strings incorrectly labeled as negative.
      #
      def false_negative
        self[:false_negative]
      end

      #
      # Returns the percentage of positive predictions that are correct
      #
      def precision
        true_positive.to_f/(true_positive + false_positive)
      end
      alias :positive_predictive_value :precision

      #
      # Returns the percentage of true negative over all negative
      #
      def negative_predictive_value
        true_negative.to_f / (true_negative + false_negative)
      end

      #
      # Returns the percentage of positive strings that were predicted as being
      # positive
      #
      def recall
        true_positive.to_f / (true_positive + false_negative)
      end
      alias :sensitivity :recall
      alias :true_positive_rate :recall

      #
      # Returns the percentage of negative strings that were predicted as being
      # negative
      #
      def specificity
        true_negative.to_f / (true_negative + false_positive)
      end
      alias :true_negative_rate :specificity

      #
      # Returns the percentage of false positives
      #
      def false_positive_rate
        false_positive.to_f / (false_positive + true_negative)
      end

      #
      # Returns the percentage of false negatives
      #
      def false_negative_rate
        false_negative.to_f / (true_positive + false_negative)
      end

      #
      # Returns the likelihood that a predicted positive is an actual positive
      #
      def positive_likelihood
        sensitivity / (1.0 - specificity)
      end

      #
      # Returns the likelihood that a predicted negative is an actual negative
      #
      def negative_likelihood
       (1.0 - sensitivity) / specificity
      end

      #
      # Returns the percentage of predictions that are correct
      #
      def accuracy
        num = (true_positive + true_negative).to_f
        den = (true_positive + true_negative + false_positive + false_negative)
        num / den
      end

      #
      # Returns the error rate
      #
      def error_rate
        num = (false_positive + false_negative).to_f
        den = (true_positive + true_negative + false_positive + false_negative)
        num / den
      end

      #
      # Returns the harmonic mean between precision and recall
      #
      def f_measure
        2.0 * (precision * recall) / (precision + recall)
      end

      #
      # Returns the balanced classification rate (arithmetic mean between
      # sensitivity and specificity)
      #
      def balanced_classification_rate
        0.5 * (sensitivity + specificity)
      end
      alias :bcr :balanced_classification_rate

      #
      # Returns the balanced error rate (1 - bcr)
      #
      def balanced_error_rate
        1.0 - balanced_classification_rate
      end
      alias :ber :balanced_error_rate

      #
      # Returns the harmonic mean between sensitivity and specificity
      #
      def harmonic_balanced_classification_rate
        2.0 * (sensitivity * specificity) / (sensitivity + specificity)
      end
      alias :hbcr :harmonic_balanced_classification_rate
      alias :harmonic_bcr :harmonic_balanced_classification_rate

      MEASURES = [
        :false_positive, :false_negative,
        :true_positive, :true_negative,
        :accuracy, :error_rate,
        :precision, :recall, :f_measure,
        :false_positive_rate, :false_negative_rate,
        :true_positive_rate, :true_negative_rate,
        :positive_predictive_value, :negative_predictive_value,
        :sensitivity, :specificity,
        :positive_likelihood, :negative_likelihood,
        :balanced_classification_rate, :balanced_error_rate, :harmonic_bcr
      ]

      def to_h
        h = {}
        MEASURES.each do |m|
          h[m] = self.send(m.to_sym)
        end
        h
      end

      def to_s
        s = ""
        MEASURES.each do |m|
          vals = case val = self.send(m.to_sym)
            when Integer
              "%s" % val
            when Float
              "%.5f" % val
            else
              "%s" % val
          end
          s += "%30s: %10s\n" % [m.to_s, vals]
        end
        s
      end

  end # module Scoring
end # module Stamina