require File.join(File.dirname(__FILE__), "induction_test")
module Stamina
  module Induction
    class RedBlueTest < Stamina::Induction::InductionTest
      
      # Factors a ready to be tested RedBlue instance
      def redblue(ufds)
        redblue = Stamina::Induction::RedBlue.new(:verbose => false)
        redblue.instance_eval do
          @ufds = ufds
        end
        redblue
      end
      
      def test_merge_and_determinize_score
        redblue = redblue(factor_ufds)
        assert_equal nil, redblue.merge_and_determinize_score(1, 0)
        assert_equal 1, redblue.merge_and_determinize_score(1, 3)
        assert_equal 1, redblue.merge_and_determinize_score(2, 0)
      end
      
      def test_main_whole_execution
        ufds = factor_ufds
        redblue = redblue(ufds)
        assert_equal [0, 1, 0, 1, 0, 1, 0, 0, 1, 0], redblue.main(ufds).to_a
      end
      
      def test_execute_whole_execution
        expected = Stamina::ADL.parse_automaton <<-EOF
          2 4
          0 true true
          1 false false
          0 0 b
          0 1 a
          1 0 b
          1 1 a
        EOF
        dfa = RedBlue.execute(@sample)
        assert_equal true, @sample.correctly_classified_by?(dfa)
        assert_equal @sample.signature, dfa.signature(@sample)
        assert_nil equivalent?(expected, dfa)
      end
            
      def test_on_dedicated_examples
        here = File.dirname(__FILE__)
        Dir["#{here}/redblue_*_sample.adl"].each do |sample_file|
          name = (/^redblue_(.*?)_sample.adl$/.match(File.basename(sample_file)))[1]
          sample = Stamina::ADL.parse_sample_file(sample_file)
          expected = Stamina::ADL.parse_automaton_file(File.join(here, "redblue_#{name}_expected.adl"))
          assert sample.correctly_classified_by?(expected)
          dfa = RedBlue.execute(sample)
          assert sample.correctly_classified_by?(dfa)
          assert_equal sample.signature, dfa.signature(sample)
          assert_nil equivalent?(expected, dfa)
        end
      end
      
      # Tests on characteristic sample
      def test_on_public_characteristic_example
        example_folder = File.join(File.dirname(__FILE__), '..', '..', '..', 'example', 'basic')
        sample = Stamina::ADL.parse_sample_file(File.join(example_folder, 'characteristic_sample.adl'))
        redblued = Stamina::Induction::RedBlue.execute(sample)
        assert_equal 4, redblued.state_count
        s0, = redblued.initial_state
        s1 = redblued.dfa_step(s0, 'b')
        s2 = redblued.dfa_step(s0, 'a')
        s3 = redblued.dfa_step(s2, 'b')
        assert_equal true, s0.accepting?
        assert_equal true, s3.accepting?
        assert_equal false, s1.accepting?
        assert_equal false, s2.accepting?
        assert_equal s1, s1.dfa_step('a')
        assert_equal s1, s1.dfa_step('b')
        assert_equal s2, s2.dfa_step('a')
        assert_equal s3, s2.dfa_step('b')
        assert_equal s3, s3.dfa_step('b')
        assert_equal s0, s3.dfa_step('a')
        assert_equal sample.signature, redblued.signature(sample)
      end
      
    end
  end
end