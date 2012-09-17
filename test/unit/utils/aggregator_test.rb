require 'stamina_test'
module Stamina
  module Utils
    class AggregatorTest < ::Stamina::StaminaTest

      def aggregator
        Aggregator.new{|g|
          g.register :price,  &:+
          g.register :origin, &:|
          g.ignore   :foo
          g.default{|v1,v2| :def}
        }
      end

      def test_merge
        expected = { :price => 30, :origin => [:s1, :s2] }
        left     = { :price => 10, :origin => [:s1] }
        right    = { :price => 20, :origin => [:s2] }
        assert_equal expected, aggregator.merge(left, right)
      end

      def test_merge_with_default
        expected = { :price => 30, :test => :def }
        left     = { :price => 10, :test => :foo }
        right    = { :price => 20, :test => :bar }
        assert_equal expected, aggregator.merge(left, right)
      end

      def test_merge_with_ignore
        expected = { :price => 30 }
        left     = { :price => 10, :foo => :bar }
        right    = { :price => 20, :foo => :bar2 }
        assert_equal expected, aggregator.merge(left, right)
      end

      def test_aggregate
        expected = { :price => 35, :origin => [:s1, :s2] }
        t1       = { :price => 10, :origin => [:s1] }
        t2       = { :price => 20, :origin => [:s2] }
        t3       = { :price => 5,  :origin => [:s2] }
        assert_equal expected, aggregator.aggregate([t1, t2, t3])
      end

    end
  end
end