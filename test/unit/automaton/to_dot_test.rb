require 'stamina_test'
module Stamina
  module Utils
    class DotTest < Test::Unit::TestCase

      def setup
        @automaton = Automaton.new do |a|
          add_state(:initial => true, :accepting => false)
          add_state(:initial => false, :accepting => true)
          add_state(:initial => false, :accepting => true, :error => true)
          connect(0, 1, 'a')
          connect(1, 0, 'b')
          connect(1, 2, 'a')
          connect(2, 2, nil)
        end
      end

      def test_attributes2dot
        attrs = {:label => 'hello'}
        assert_equal 'label="hello"', @automaton.send(:attributes2dot, attrs)
        attrs = {:label => 'hello', :color => 'red'}
        assert_equal 'color="red" label="hello"', @automaton.send(:attributes2dot, attrs)
        attrs = {:label => 'O"Neil'}
        assert_equal 'label="O\"Neil"', @automaton.send(:attributes2dot, attrs)
      end

      def test_automaton_to_dot_with_default_rewriter
        expected = <<-EOF
          #digraph G {
          #  graph [margin="0" pack="true" rankdir="LR" ranksep="0"];
          #  0 [color="black" fillcolor="green" fixedsize="true" height="0.6" shape="circle" style="filled" width="0.6"];
          #  1 [color="black" fillcolor="white" fixedsize="true" height="0.6" shape="doublecircle" style="filled" width="0.6"];
          #  2 [color="black" fillcolor="red" fixedsize="true" height="0.6" shape="doublecircle" style="filled" width="0.6"];
          #  0 -> 1 [arrowsize="0.7" label="a"];
          #  1 -> 0 [arrowsize="0.7" label="b"];
          #  1 -> 2 [arrowsize="0.7" label="a"];
          #  2 -> 2 [arrowsize="0.7" label=""];
          #}
        EOF
        expected = expected.gsub(/^\s+#/,'')
        assert_equal expected, @automaton.to_dot
      end

      def test_automaton_with_specific_rewriter
        expected = <<-EOF
          #digraph G {
          #  graph [];
          #  0 [accepting="false" initial="true"];
          #  1 [accepting="true" initial="false"];
          #  2 [accepting="true" error="true" initial="false"];
          #  0 -> 1 [symbol="a"];
          #  1 -> 0 [symbol="b"];
          #  1 -> 2 [symbol="a"];
          #  2 -> 2 [symbol=""];
          #}
        EOF
        expected = expected.gsub(/^\s+#/,'')
        assert_equal expected, @automaton.to_dot {|elm,kind| elm.data}
      end

    end
  end
end