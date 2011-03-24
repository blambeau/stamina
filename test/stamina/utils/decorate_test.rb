require 'stamina'
require 'stamina/utils/decorate'
require 'stamina/stamina_test'
require 'test/unit'
module Stamina
  module Utils
    class DecorateTest < ::Stamina::StaminaTest
      
      module Reachability
        def suppremum(d0, d1) d0 || d1; end
        def propagate(deco, edge) deco; end
      end
      
      module Depth
        def suppremum(d0, d1) (d0 < d1 ? d0 : d1) end
        def propagate(deco, edge) deco+1; end
      end
      
      module ShortPrefix
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
        algo = Stamina::Utils::Decorate.new(:reachable)
        algo.set_suppremum {|d0,d1|  d0 || d1 }
        algo.set_propagate {|deco,edge| deco }
        algo.execute(@small_dfa, false, true)
        assert_equal @small_dfa.states.select {|s| s[:reachable]==true}, @small_dfa.states
        
        algo = Stamina::Utils::Decorate.new(:reachable)
        algo.extend(Reachability)
        algo.execute(@small_dfa, false, true)
        assert_equal @small_dfa.states.select {|s| s[:reachable]==true}, @small_dfa.states
      end
      
      def test_depth_on_small_dfa
        algo = Stamina::Utils::Decorate.new(:depth)
        algo.extend(Depth)
        algo.execute(@small_dfa, 1000000, 0)
        assert_equal 0, @small_dfa.ith_state(3)[:depth]
        assert_equal 1, @small_dfa.ith_state(2)[:depth]
        assert_equal 2, @small_dfa.ith_state(0)[:depth]
        assert_equal 3, @small_dfa.ith_state(1)[:depth]
      end
      
      def test_depth_on_small_dfa
        algo = Stamina::Utils::Decorate.new(:short_prefix)
        algo.extend(ShortPrefix)
        algo.execute(@small_dfa, nil, [])
        assert_equal [], @small_dfa.ith_state(3)[:short_prefix]
        assert_equal ['b'], @small_dfa.ith_state(2)[:short_prefix]
        assert_equal ['b', 'c'], @small_dfa.ith_state(0)[:short_prefix]
        assert_equal ['b', 'c', 'a'], @small_dfa.ith_state(1)[:short_prefix]
      end
      
    end
  end
end
