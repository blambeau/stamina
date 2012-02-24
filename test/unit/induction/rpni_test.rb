require File.join(File.dirname(__FILE__), "induction_test")
module Stamina
  module Induction
    class RPNITest < Stamina::Induction::InductionTest
      include Stamina::Induction::Commons

      # Factors a ready to be used RPNI instance with an initial UnionFind.
      def rpni(ufds)
        rpni = RPNI.new(:verbose => false)
        rpni.instance_eval do
          @ufds = ufds
        end
        rpni
      end

      # Returns index-th state of the PTA
      def s(index)
        @pta.ith_state(index)
      end

      def test_compatible_merge_and_determinize_without_determinize
        rpni = rpni(factor_ufds)
        assert_equal true, rpni.merge_and_determinize(0, 4)
        assert_equal [0, 1, 2, 3, 0, 5, 6, 7, 8, 9], rpni.ufds.to_a
      end

      def test_compatible_merge_and_determinize_with_one_determinize
        rpni = rpni(factor_ufds)
        assert_equal true, rpni.merge_and_determinize(2, 7)
        assert_equal [0, 1, 2, 3, 4, 5, 6, 2, 5, 6], rpni.ufds.to_a
      end

      def test_incompatible_merge_and_determinize_without_determinize
        rpni = rpni(factor_ufds)
        assert_equal false, rpni.merge_and_determinize(0, 1)
        assert_equal [0, 0, 2, 3, 4, 5, 6, 7, 8, 9], rpni.ufds.to_a
      end

      def test_incompatible_merge_and_determinize_with_two_determinize
        rpni = rpni(factor_ufds)
        assert_equal false, rpni.merge_and_determinize(5, 0)
        assert_equal [0, 1, 2, 3, 4, 0, 6, 2, 0, 9], rpni.ufds.to_a
      end

      def execution_step(rpni, i, j, success, expected=nil)
        before = rpni.ufds.to_a
        assert_equal success, rpni.successfull_merge_or_nothing(i, j)
        if success
          assert_equal(expected, rpni.ufds.to_a) if expected
        else
          assert_equal before, rpni.ufds.to_a
        end
      end

      def test_step_by_step_whole_execution
        rpni = rpni(factor_ufds)
        execution_step(rpni,1,0,false)
        execution_step(rpni,2,0,true,[0, 1, 0, 3, 4, 1, 0, 4, 8, 9])
        execution_step(rpni,3,0,false)
        execution_step(rpni,3,1,true,[0, 1, 0, 1, 4, 1, 0, 4, 8, 9])
        execution_step(rpni,4,0,true,[0, 1, 0, 1, 0, 1, 0, 0, 1, 0])

        ufds = factor_ufds
        rpni = rpni(ufds)
        assert_equal [0, 1, 0, 1, 0, 1, 0, 0, 1, 0], rpni.main(ufds).to_a
      end

      def test_main_whole_execution
        ufds = factor_ufds
        rpni = rpni(ufds)
        assert_equal [0, 1, 0, 1, 0, 1, 0, 0, 1, 0], rpni.main(ufds).to_a
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
        dfa = RPNI.execute(@sample)
        assert_equal true, @sample.correctly_classified_by?(dfa)
        assert_equal @sample.signature, dfa.signature(@sample)
        assert_nil equivalent?(expected, dfa)
      end

      def test_on_dedicated_examples
        here = File.dirname(__FILE__)
        Dir["#{here}/rpni_*_sample.adl"].each do |sample_file|
          name = (/^rpni_(.*?)_sample.adl$/.match(File.basename(sample_file)))[1]
          sample = Stamina::ADL.parse_sample_file(sample_file)
          expected = Stamina::ADL.parse_automaton_file(File.join(here, "rpni_#{name}_expected.adl"))
          assert sample.correctly_classified_by?(expected)
          dfa = RPNI.execute(sample)
          assert sample.correctly_classified_by?(dfa)
          assert_equal sample.signature, dfa.signature(sample)
          assert_nil equivalent?(expected, dfa)
        end
      end

      # Tests on characteristic sample
      def test_on_public_characteristic_example
        sample = Stamina::ADL.parse_sample_file(File.expand_path('../characteristic.adl', __FILE__))
        rpnied = Stamina::Induction::RPNI.execute(sample)
        assert_equal 4, rpnied.state_count
        s0, = rpnied.initial_state
        s1 = rpnied.dfa_step(s0, 'b')
        s2 = rpnied.dfa_step(s0, 'a')
        s3 = rpnied.dfa_step(s2, 'b')
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
        assert_equal sample.signature, rpnied.signature(sample)
      end

    end
  end
end