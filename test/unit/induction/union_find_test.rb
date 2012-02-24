require 'test/unit'
require 'stamina/induction/union_find'
module Stamina
  module Induction
    class UnionFindTest < Test::Unit::TestCase

      def assert_whole_find_is(expected, ufds)
        0.upto(expected.size-1) do |i|
          assert_equal expected[i], ufds.find(i)
        end
      end

      def test_initially
        ufds = UnionFind.new(5)
        assert_equal 5, ufds.size
        0.upto(ufds.size-1) do |i|
          assert_equal i, ufds.find(i)
          assert_equal true, ufds.leader?(i)
        end
      end

      def test_one_union
        ufds = UnionFind.new(5)
        ufds.union(3,0)
        assert_whole_find_is [0, 1, 2, 0, 4], ufds
        assert_equal true, ufds.leader?(0)
        assert_equal false, ufds.leader?(3)

        ufds = UnionFind.new(5)
        ufds.union(0,3)
        assert_whole_find_is [0, 1, 2, 0, 4], ufds
      end

      def test_two_unions
        ufds = UnionFind.new(5)
        ufds.union(3,0)
        ufds.union(4,3)
        assert_whole_find_is [0, 1, 2, 0, 0], ufds
        assert_equal true, ufds.leader?(0)
        assert_equal false, ufds.leader?(3)
        assert_equal false, ufds.leader?(4)
      end

      def test_three_unions
        ufds = UnionFind.new(5)
        ufds.union(3,0)
        ufds.union(1,2)
        ufds.union(2,4)
        assert_equal true, ufds.leader?(0)
        assert_equal true, ufds.leader?(1)
        assert_equal false, ufds.leader?(2)
        assert_equal false, ufds.leader?(3)
        assert_equal false, ufds.leader?(4)
      end

      def test_union_supports_identity_union
        ufds = UnionFind.new(5)
        ufds.union(0,0)
        assert_whole_find_is [0, 1, 2, 3, 4], ufds
        ufds.union(1,0)
        assert_whole_find_is [0, 0, 2, 3, 4], ufds
        ufds.union(1,0)
        assert_whole_find_is [0, 0, 2, 3, 4], ufds
        ufds.union(0,1)
        assert_whole_find_is [0, 0, 2, 3, 4], ufds
      end

      def test_dup
        ufds = UnionFind.new(5)
        ufds.union(3,0)
        copy = ufds.dup
        (0...5).each {|i| assert_equal ufds.find(i), copy.find(i)}
        copy.union(4,3)
        assert_equal 0, copy.find(4)
        assert_equal 4, ufds.find(4)
      end

      def test_transactional_support
        ufds = UnionFind.new(5)
        ufds.save_point
        ufds.union(3,0)
        assert_whole_find_is [0, 1, 2, 0, 4], ufds
        ufds.commit
        assert_whole_find_is [0, 1, 2, 0, 4], ufds
        ufds.save_point
        ufds.union(4,3)
        assert_whole_find_is [0, 1, 2, 0, 0], ufds
        ufds.rollback
        assert_whole_find_is [0, 1, 2, 0, 4], ufds
      end

      def test_validity_of_rdoc_example
        # create a union-find for 10 elements
        ufds = Stamina::Induction::UnionFind.new(10) do |index|
          # each element will be associated with a hash with data of interest:
          # smallest element, greatest element and concatenation of names
          {:smallest => index, :greatest => index, :names => index.to_s}
        end

        # each element is its own leader
        assert_equal true, (0...10).all?{|s| ufds.leader?(s)}
        assert_equal false, (0...10).all?{|s| ufds.slave?(s)}

        # and their respective group number are the element indices themselve
        assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], ufds.to_a

        # now, let merge 4 with 0
        ufds.union(0, 4) do |d0, d4|
          {:smallest => d0[:smallest] < d4[:smallest] ? d0[:smallest] : d4[:smallest],
           :greatest => d0[:smallest] > d4[:smallest] ? d0[:smallest] : d4[:smallest],
           :names => d0[:names] + " " + d4[:names]}
        end

        # let see what happens on group numbers
        assert_equal [0, 1, 2, 3, 0, 5, 6, 7, 8, 9], ufds.to_a

        # let now have a look on mergeable_data of the group of 0 (same result for 4)
        expected = {:smallest => 0, :greatest => 4, :names => "0 4"}
        assert_equal expected, ufds.mergeable_data(0)
      end

    end
  end
end