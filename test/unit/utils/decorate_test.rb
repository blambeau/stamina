require 'stamina_test'
module Stamina
  module Utils
    class DecorateTest < ::Stamina::StaminaTest

      module Reachability
        def init_deco(s) s.initial?; end
        def take_at_start?(s) s.initial?; end
        def suppremum(d0, d1) d0 || d1; end
        def propagate(deco, edge) deco; end
      end

      module Depth
        def init_deco(s) s.initial? ? 0 : 1000000; end
        def take_at_start?(s) s.initial?; end
        def suppremum(d0, d1) (d0 < d1 ? d0 : d1) end
        def propagate(deco, edge) deco+1; end
      end

      module ShortPrefix
        def init_deco(s) s.initial? ? [] : nil; end
        def take_at_start?(s) s.initial?; end
        def suppremum(d0, d1)
          return d0 if d1.nil?
          return d1 if d0.nil?
          d0.size <= d1.size ? d0 : d1
        end
        def propagate(deco, edge)
          deco.dup << edge.symbol
        end
      end

      def test_reachability_on_small_dfa
        algo = Stamina::Utils::Decorate.new
        algo.set_suppremum {|d0,d1|  d0 || d1 }
        algo.set_propagate {|deco,edge| deco }
        algo.set_initiator {|s| s.initial?}
        algo.set_start_predicate{|s| s.initial?}
        algo.call(@small_dfa, :reachable)
        assert_equal @small_dfa.states.select{|s| s[:reachable]==true}, @small_dfa.states

        algo = Stamina::Utils::Decorate.new
        algo.extend(Reachability)
        algo.call(@small_dfa, :reachable)
        assert_equal @small_dfa.states.select{|s| s[:reachable]==true}, @small_dfa.states
      end

      def test_depth_on_small_dfa
        algo = Stamina::Utils::Decorate.new
        algo.extend(Depth)
        algo.call(@small_dfa, :depth)
        assert_equal 0, @small_dfa.ith_state(3)[:depth]
        assert_equal 1, @small_dfa.ith_state(2)[:depth]
        assert_equal 2, @small_dfa.ith_state(0)[:depth]
        assert_equal 3, @small_dfa.ith_state(1)[:depth]
      end

      def test_short_prefix_on_small_dfa
        algo = Stamina::Utils::Decorate.new
        algo.extend(ShortPrefix)
        algo.call(@small_dfa, :short_prefix)
        assert_equal [], @small_dfa.ith_state(3)[:short_prefix]
        assert_equal ['b'], @small_dfa.ith_state(2)[:short_prefix]
        assert_equal ['b', 'c'], @small_dfa.ith_state(0)[:short_prefix]
        assert_equal ['b', 'c', 'a'], @small_dfa.ith_state(1)[:short_prefix]
      end

    end
  end
end