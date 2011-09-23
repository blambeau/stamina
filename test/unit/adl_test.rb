require 'stamina_test'
module Stamina

  # Tests ADL parser
  class ADLTest < Test::Unit::TestCase
  
    # Tests ADL#parse on a valid dfa
    def test_can_parse_valid_empty_dfa
      fa = ADL::parse_automaton <<-AUTOMATON
        1 0
        0 true false
      AUTOMATON
      assert_equal(1, fa.state_count)
      assert_equal(0, fa.edge_count)
      assert_equal(true, fa.states[0].initial?)
      assert_equal(false, fa.states[0].accepting?)
      assert_equal(true, fa.deterministic?)
      assert_equal(false, fa.accepts?('+'))
      assert_equal(false, fa.accepts?('+ a'))
    end
  
    # Tests ADL#parse on a valid dfa
    def test_can_parse_valid_small_dfa
      fa = ADL::parse_automaton <<-AUTOMATON
        3 4
        0 true false
        1 false false
        2 false true
        0 1 a
        1 2 b
        2 2 a
        2 1 b
      AUTOMATON
      assert_equal(3, fa.state_count)
      assert_equal(4, fa.edge_count)
      fa.each_state {|s| assert_equal(s.index==0, s.initial?)}
      fa.each_state {|s| assert_equal(s.index==2, s.accepting?)}
      assert_equal(false, fa.accepts?('+'))
      assert_equal(false, fa.accepts?('+ a'))
      assert_equal(true, fa.accepts?('+ a b'))
      assert_equal(true, fa.accepts?('+ a b a'))
      assert_equal(false, fa.accepts?('+ a b a b'))
      assert_equal(true, fa.accepts?('+ a b a a a'))
      assert_equal(true, fa.accepts?('+ a b a a a b b a'))
      assert_equal(true, fa.accepts?('+ a b a a a b b a a a'))
      assert_equal(true, fa.accepts?('+ a b a a a b b a a a b b a'))
    end
  
    # Tests that ADL#parse detects a missing state
    def test_detect_missing_header
      assert_raise(ADL::ParseError) do
        ADL::parse_automaton <<-AUTOMATON
          0 true false
          1 false false
          0 1 a
          1 2 b
          2 2 a
          2 1 b
        AUTOMATON
      end
      assert_raise(ADL::ParseError) do
        ADL::parse_automaton <<-AUTOMATON
          # 3 4
          0 true false
          1 false false
          0 1 a
          1 2 b
          2 2 a
          2 1 b
        AUTOMATON
      end
    end
  
    # Tests that ADL#parse detects a missing state
    def test_detect_missing_state
      assert_raise(ADL::ParseError) do
        ADL::parse_automaton <<-AUTOMATON
          3 4
          0 true false
          1 false false
        AUTOMATON
      end
      assert_raise(ADL::ParseError) do
        ADL::parse_automaton <<-AUTOMATON
          3 4
          0 true false
          1 false false
          0 1 a
          1 2 b
          2 2 a
          2 1 b
        AUTOMATON
      end
      assert_raise(ADL::ParseError) do
        ADL::parse_automaton <<-AUTOMATON
          3 4
          0 true false
          1 false false
          # 2 false true
          0 1 a
          1 2 b
          2 2 a
          2 1 b
        AUTOMATON
      end
    end
  
    # Tests that ADL#parse detects a missing edge
    def test_detect_missing_edge
      assert_raise(ADL::ParseError) do
        ADL::parse_automaton <<-AUTOMATON
          3 4
          0 true false
          1 false false
          2 false true
          0 1 a
          2 2 a
          2 1 b
        AUTOMATON
      end
      assert_raise(ADL::ParseError) do
        ADL::parse_automaton <<-AUTOMATON
          3 4
          0 true false
          1 false false
          2 false true
          0 1 a
          1 2 b
          2 2 a
          # 2 1 b
        AUTOMATON
      end
    end

    # Tests that ADL#parse detects a missing edge
    def test_detect_trailing_data
      assert_raise(ADL::ParseError) do
        fa = ADL::parse_automaton <<-AUTOMATON
          1 0
          0 true false
          trailing here
        AUTOMATON
      end
    end
  
    # Tests that ADL#parse detects a missing edge
    def test_allows_comments_and_white_lines
      fa = nil
      assert_nothing_raised(ADL::ParseError) do
        fa = ADL::parse_automaton <<-AUTOMATON
      
          # a header is always allowed,
          # with empty lines as well
          #
          3 4
        
          # state definitions may be introduced...
          0 true false
          1 false false
          # and perturbated
          2 false true
          0 1 a
        
          # edge introduction may be misplaced
          1 2 b
          2 2 a
        
          2 1 b
        
          # and end of file may contain documentation as well
          # as empty lines:
        
        AUTOMATON
      end
      assert_equal(3, fa.state_count)
      assert_equal(4, fa.edge_count)
      fa.each_state {|s| assert_equal(s.index==0, s.initial?)}
      fa.each_state {|s| assert_equal(s.index==2, s.accepting?)}
      assert_equal(false, fa.accepts?('+'))
      assert_equal(false, fa.accepts?('+ a'))
      assert_equal(true, fa.accepts?('+ a b'))
      assert_equal(true, fa.accepts?('+ a b a'))
      assert_equal(false, fa.accepts?('+ a b a b'))
      assert_equal(true, fa.accepts?('+ a b a a a'))
      assert_equal(true, fa.accepts?('+ a b a a a b b a'))
      assert_equal(true, fa.accepts?('+ a b a a a b b a a a'))
      assert_equal(true, fa.accepts?('+ a b a a a b b a a a b b a'))
    end
  
    # Tests ADL::parse on the documentation example
    def test_valid_adl_automaton_example
      fa = nil
      assert_nothing_raised(ADL::ParseError) do
        here =  File.dirname(__FILE__)
        automaton_adl = File.join(here, '..', '..', 'example', 'adl', 'automaton.adl')
        fa = ADL::parse_automaton_file(automaton_adl)
      end # assert_nothing_raised
      assert_equal(5, fa.state_count)
      assert_equal(6, fa.edge_count)
      assert_equal(true, fa.parses?('? hello w o r l d'))
      assert_equal(false, fa.accepts?('? hello w o r l d'))
      assert_equal(true, fa.rejects?('? hello w o r l d'))
      assert_equal(true, fa.accepts?('? hello'))
      assert_equal(false, fa.accepts?('? hello w'))
      assert_equal(true, fa.accepts?('? hello w o'))
      assert_equal(false, fa.accepts?('? hello w o r'))
      assert_equal(false, fa.accepts?('? hello w o r l'))
    end
  
    # Tests ADL::parse on the documentation succint example
    def test_valid_adl_automaton_succint_example
      fa = nil
      assert_nothing_raised do
        fa = ADL::parse_automaton <<-AUTOMATON
          # Some header comments: tool which has generated this automaton,
          # maybe a date or other tool options ...
          # here: 'this automaton accepts the a(ba)* regular language'
          2 2
          0 true false
          1 false true
          0 1 a
          1 0 b
        AUTOMATON
      end
      assert_equal(2, fa.state_count)
      assert_equal(2, fa.edge_count)
      assert_equal(true, fa.accepts?('? a'))
      assert_equal(true, fa.accepts?('? a b a'))
      assert_equal(true, fa.accepts?('? a b a b a'))
      assert_equal(false, fa.accepts?('?'))
      assert_equal(false, fa.accepts?('? a b'))
      assert_equal(false, fa.accepts?('? a b a b'))
    end
  
    # Checks that an initial state may arruve lately
    def test_parse_automaton_allows_late_initial_state
      fa = nil
      assert_nothing_raised do
        fa = ADL::parse_automaton <<-AUTOMATON
          # Some header comments: tool which has generated this automaton,
          # maybe a date or other tool options ...
          # here: 'this automaton accepts the a(ba)* regular language'
          2 2
          0 false false
          1 true true
          0 1 a
          1 0 b
        AUTOMATON
      end
    end
  
    # Tests parse_automaton on an automated randomly generated using jail
    def test_parse_automaton_on_jail_randdfa
      fa = nil
      assert_nothing_raised do
        fa = ADL::parse_automaton_file(File.join(File.dirname(__FILE__),'randdfa.adl'))
      end
    end
  
    # Tests an important security issue about parse_automaton
    def test_parse_automaton_does_not_executes_ruby_code
      begin 
        assert_raise ADL::ParseError do
          ADL::parse_automaton <<-AUTOMATON
          Kernel.exit(-1)
          AUTOMATON
        end
      rescue SystemExit
        assert false, 'SECURITY issue: ADL::parse_automaton executes ruby code'
      end
      begin 
        assert_raise ADL::ParseError do
          ADL::parse_automaton_file(File.dirname(__FILE__)+'/exit.rb') 
        end
      rescue SystemExit
        assert false, 'SECURITY issue: ADL::parse_automaton executes ruby code'
      end
    end
  
    # Tests ADL::parse_string
    def test_parse_string
      s = ADL::parse_string('?')
      assert_equal(true, InputString===s)
      assert_equal(false, s.positive?)
      assert_equal(false, s.negative?)
      assert_equal(true, s.unlabeled?)
      assert_equal(nil, s.label)
      assert_equal(true, s.empty?)
      assert_equal([], s.symbols)

      s = ADL::parse_string('+')
      assert_equal(true, InputString===s)
      assert_equal(true, s.positive?)
      assert_equal(true, s.label)
      assert_equal(true, s.empty?)
      assert_equal([], s.symbols)
    
      s = ADL::parse_string('-')
      assert_equal(true, InputString===s)
      assert_equal(false, s.positive?)
      assert_equal(false, s.label)
      assert_equal(true, s.empty?)
      assert_equal([], s.symbols)
    
      s = ADL::parse_string('? a')
      assert_equal(['a'], s.symbols)
      assert_equal(false, s.positive?)
      assert_equal(false, s.negative?)
      assert_equal(true, s.unlabeled?)
      assert_equal(nil, s.label)
      assert_equal(['a'], s.symbols)
    
      s = ADL::parse_string('+ a')
      assert_equal(['a'], s.symbols)
      assert_equal(true, s.positive?)
    
      s = ADL::parse_string('- a')
      assert_equal(['a'], s.symbols)
      assert_equal(false, s.positive?)
    
      s = ADL::parse_string('+ a b a b ')
      assert_equal(['a','b','a','b'], s.symbols)
      assert_equal(true, s.positive?)
    
      s = ADL::parse_string('- a b a c')
      assert_equal(['a','b','a','c'], s.symbols)
      assert_equal(false, s.positive?)
    end
  
    # Tests ADL::parse_sample
    def test_parse_sample
      sample = ADL::parse_sample <<-SAMPLE
      + a b  a b  a b
      # this is a comment, next is an empty line
      +
      + a   b
      - a a
      ? a b
      # trailing comment allowed
      SAMPLE
      assert sample==Sample['+ a b a b a b', '+ a b', '- a a', '+', '? a b']
    end
  
    # Tests that ADL::parse_sample accepts the empty sample
    def test_parse_sample_accepts_empty_sample
      samples = [
        ADL::parse_sample(""),
        ADL::parse_sample("#"),
        ADL::parse_sample(<<-SAMPLE 
        SAMPLE
        ),
        ADL::parse_sample(<<-SAMPLE
        
          # this is a comment, between two empty lines
      
        SAMPLE
        )
      ]
      samples.each do |sample|
        assert sample==Sample.new
      end
    end
  
    # Tests that ADL::parse_sample accepts empty strings
    def test_parse_sample_accepts_empty_strings
      assert Sample['+'] == ADL::parse_sample('+')
      assert Sample['-'] == ADL::parse_sample('-')
      assert Sample['+'] == ADL::parse_sample(<<-SAMPLE
        +
      SAMPLE
      )
      assert Sample['-'] == ADL::parse_sample(<<-SAMPLE
        -
      SAMPLE
      )
    end  
  
    # Tests validity of sample.adl file
    def test_valid_adl_sample_example
      here =  File.dirname(__FILE__)
      sample_adl = File.join(here, '..', '..', 'example', 'adl', 'sample.adl')
      sample = ADL::parse_sample_file(sample_adl)
      expected = Sample.new 
      expected << InputString.new(['a', 'b', 'a', 'b'], true)
      expected << InputString.new(['a', 'a'], false)
      expected << InputString.new(['a', 'b'], nil)
      expected << InputString.new([], true)
      expected << InputString.new(['hello', 'world'], true)
      expected << InputString.new(['h','e','l','l','o','w','o','r','l','d'], true)
      expected << InputString.new(['helloworld'], true)
      expected << InputString.new(['a','+','b','-','a','-','b','+a'], true)
      expected << InputString.new(['#','a','#','b','a','b','#','and','all','these','words','are','symbols', 'too', '!!'],true)
      expected.each do |s|
        assert sample.include?(s), "|#{s}| from expected is included in sample"
      end
      sample.each do |s|
        assert expected.include?(s), "|#{s}| from sample is included in expected"
      end
      assert expected == sample
    end

    # Tests validity of sample.adl file
    def test_valid_adl_sample_succint_example
      sample = ADL::parse_sample <<-SAMPLE
        # Some header comments: tool which has generated this sample,
        # maybe a date or other tool options ...
        # here: 'this sample is caracteristic for the a(ba)* regular language'
        -
        + a
        - a b
        + a b a
      SAMPLE
      expected = Sample.new
      expected << InputString.new([], false)
      expected << InputString.new(['a'], true)
      expected << InputString.new(['a','b'], false)
      expected << InputString.new(['a','b','a'], true)
      assert expected==sample
    end  
  
    # Tests an important security issue about parse_automaton
    def test_parse_sample_does_not_executes_ruby_code
      begin 
        ADL::parse_sample <<-AUTOMATON
        + Kernel.exit(-1)
        AUTOMATON
      rescue SystemExit
        assert false, 'SECURITY issue: ADL::parse_automaton executes ruby code'
      end
      begin 
        ADL::parse_sample_file(File.dirname(__FILE__)+'/exit.rb') 
      rescue SystemExit
        assert false, 'SECURITY issue: ADL::parse_automaton executes ruby code'
      end
    end

    # tests that state IDs are loaded and can be used.
    def test_state_names
      fa = ADL::parse_automaton <<-AUTOMATON
        3 4
        A true false
        B false false
        C false true
        A B a
        B C b
        C C a
        C B b
      AUTOMATON

      ['A','B','C'].each do |statename|
        assert_equal statename,fa.get_state(statename)[:name]
      end

      assert_equal true,fa.get_state('A').initial?
      assert_equal false,fa.get_state('B').initial?
      assert_equal false,fa.get_state('C').initial?

      assert_equal false,fa.get_state('A').accepting?
      assert_equal false,fa.get_state('B').accepting?
      assert_equal true,fa.get_state('C').accepting?
    end
  
    def test_parsing_recognizes_failures
      assert_raise Stamina::ADL::ParseError do 
        fa = ADL::parse_sample <<-EOF
          3 4
          A true false
          B false false
          C false true
          A B a
          B C b
          C C a
          C B b
        EOF
      end
      assert_raise Stamina::ADL::ParseError do 
        sample = ADL::parse_automaton <<-EOF
          + a b  a b  a b
          # this is a comment, next is an empty line
          +
          + a   b
          - a a
          a b
          # trailing comment allowed
        EOF
      end
    end

    def test_allows_error_states
      dfa = ADL::parse_automaton <<-EOF
        5 0
        0 true true true
        1 false false true
        2 false false false
        3 false true false
        4 false true
      EOF
      assert dfa.ith_state(0).accepting? && dfa.ith_state(0).error?
      assert !dfa.ith_state(1).accepting? && dfa.ith_state(1).error?
      assert !dfa.ith_state(2).accepting? && !dfa.ith_state(2).error?
      assert dfa.ith_state(3).accepting? && !dfa.ith_state(3).error?
      assert !dfa.ith_state(4).error?
    end

    def test_flushes_error_states
      dfa = ADL::parse_automaton <<-EOF
        2 0
        0 true false
        1 false false true
      EOF
      assert_equal "1 false false true", dfa.to_adl.split("\n")[2].strip
    end

  end # class ADLTest
end # module Stamina
