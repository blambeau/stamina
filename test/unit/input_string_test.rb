require 'stamina_test'
module Stamina
  
# Tests InputString class
class InputStringTest < Test::Unit::TestCase
  
  # Tests on empty string
  def test_on_empty_string
    # with empty array of symbols, positively labeled
    s = InputString.new([], true)
    assert_equal(0, s.size)
    assert_equal(true, s.empty?)
    assert_equal(true, s.lambda?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(true, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(false, s.unlabeled?)
    assert_equal(true, s.label)
    
    # with empty array of symbols, negatively labeled
    s = InputString.new([], false)
    assert_equal(0, s.size)
    assert_equal(true, s.empty?)
    assert_equal(true, s.lambda?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(true, s.negative?)
    assert_equal(false, s.unlabeled?)
    assert_equal(false, s.label)
    
    # with empty array of symbols, unlabeled
    s = InputString.new([], nil)
    assert_equal(0, s.size)
    assert_equal(true, s.empty?)
    assert_equal(true, s.lambda?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(true, s.unlabeled?)
    assert_equal(nil, s.label)
    
    # with empty string, positively labeled
    s = InputString.new('', true)
    assert_equal(0, s.size)
    assert_equal(true, s.lambda?)
    assert_equal(true, s.empty?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(true, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(false, s.unlabeled?)
    
    # with empty string, negatively labeled
    s = InputString.new('', false)
    assert_equal(0, s.size)
    assert_equal(true, s.lambda?)
    assert_equal(true, s.empty?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(true, s.negative?)
    assert_equal(false, s.unlabeled?)
    
    # with empty string, unlabeled
    s = InputString.new('', nil)
    assert_equal(0, s.size)
    assert_equal(true, s.lambda?)
    assert_equal(true, s.empty?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(true, s.unlabeled?)

    # with empty string with trailing whitespaces, positively labeled
    s = InputString.new("   ", true)
    assert_equal(0, s.size)
    assert_equal(true, s.lambda?)
    assert_equal(true, s.empty?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(true, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(false, s.unlabeled?)
    
    # with empty string with trailing whitespaces, negatively labeled
    s = InputString.new("  ", false)
    assert_equal(0, s.size)
    assert_equal(true, s.lambda?)
    assert_equal(true, s.empty?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(true, s.negative?)
    assert_equal(false, s.unlabeled?)
    
    # with empty string with trailing whitespaces, unlabeled
    s = InputString.new("  ", nil)
    assert_equal(0, s.size)
    assert_equal(true, s.lambda?)
    assert_equal(true, s.empty?)
    assert_equal([], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(true, s.unlabeled?)

    # with empty string with trailing whitespaces, negatively labeled
    s = InputString.new(" \n  \t \t\n ", false)
    assert_equal(0, s.size)
    assert_equal(true, s.empty?)
    assert_equal([], s.symbols)
  end
  
  # Tests with a string of only one character
  def test_on_one_character_string
    # with array of symbols, positively labeled
    s = InputString.new(['a'], true)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(false, s.lambda?)
    assert_equal(['a'], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(true, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(false, s.unlabeled?)
    assert_equal(true, s.label)
    
    # with empty array of symbols, negatively labeled
    s = InputString.new(['a'], false)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(['a'], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(true, s.negative?)
    assert_equal(false, s.label)
    
    # with empty array of symbols, unlabeled
    s = InputString.new(['a'], nil)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(['a'], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(false, s.negative?)
    assert_equal(true, s.unlabeled?)
    assert_equal(nil, s.label)
    
    # with empty string, positively labeled
    s = InputString.new('a', true)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(['a'], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(true, s.positive?)
    assert_equal(false, s.negative?)
    
    # with empty string, negatively labeled
    s = InputString.new('a', false)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(['a'], s.symbols)
    assert_equal(true, s.symbols.frozen?)
    assert_equal(false, s.positive?)
    assert_equal(true, s.negative?)

    # with empty string with trailing whitespaces, positively labeled
    s = InputString.new("a  ", true)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(['a'], s.symbols)

    # with empty string with trailing whitespaces, positively labeled
    s = InputString.new("  a", true)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(['a'], s.symbols)

    # with empty string with trailing whitespaces, positively labeled
    s = InputString.new("  \na  \t \n", true)
    assert_equal(1, s.size)
    assert_equal(false, s.empty?)
    assert_equal(['a'], s.symbols)
  end
  
  def test_negate
    assert_equal InputString.new([], true), InputString.new([], false).negate 
    assert_equal InputString.new([], false), InputString.new([], true).negate 
    assert_equal InputString.new([], nil), InputString.new([], nil).negate 
    assert_equal InputString.new(['a'], true), InputString.new(['a'], false).negate 
    assert_equal InputString.new(['a'], false), InputString.new(['a'], true).negate 
    assert_equal InputString.new(['a'], nil), InputString.new(['a'], nil).negate 
  end
  
  # Tests on a small size string.
  def test_on_small_size_string
    s = InputString.new(['a', 'b', 'c', 'a'], true)
    assert_equal(false, s.empty?)
    assert_equal(4, s.size)
    assert_equal(['a', 'b', 'c', 'a'], s.symbols)
    assert_equal(true, s.positive?)

    s = InputString.new('a b c a', false)
    assert_equal(false, s.empty?)
    assert_equal(4, s.size)
    assert_equal(['a', 'b', 'c', 'a'], s.symbols)
    assert_equal(false, s.positive?)

    s = InputString.new('a b c a', nil)
    assert_equal(false, s.empty?)
    assert_equal(4, s.size)
    assert_equal(['a', 'b', 'c', 'a'], s.symbols)
    assert_equal(true, s.unlabeled?)

    s = InputString.new('a b c a', false)
    assert_equal(false, s.empty?)
    assert_equal(4, s.size)
    assert_equal(['a', 'b', 'c', 'a'], s.symbols)

    s = InputString.new("  a b   c a\t", true)
    assert_equal(false, s.empty?)
    assert_equal(4, s.size)
    assert_equal(['a', 'b', 'c', 'a'], s.symbols)
  end
  
  # Tests that s.symbols.dup returns a modifiable array
  def test_symbols_duplication_may_be_modified
    s = InputString.new([''], true)
    assert_equal(false, s.symbols.dup.frozen?)
    
    s = InputString.new(['a' 'b' 'c' 'a'], true)
    assert_equal(false, s.symbols.dup.frozen?)
    
    s = InputString.new('', true)
    assert_equal(false, s.symbols.dup.frozen?)
    
    s = InputString.new('a b c a', true)
    assert_equal(false, s.symbols.dup.frozen?)
  end
  
  # Tests InputString#==
  def test_equality
    s = InputString.new([], true)
    assert_equal(s, InputString.new([], true))
    assert_equal(s, InputString.new('', true))
    assert_equal(s, InputString.new(' ', true))
    assert_not_equal(s, InputString.new([], false))
    assert_not_equal(s, InputString.new(['a'], false))
    assert_not_equal(s, InputString.new([], nil))

    s = InputString.new([], false)
    assert_equal(s, InputString.new([], false))
    assert_equal(s, InputString.new('', false))
    assert_equal(s, InputString.new(' ', false))
    assert_not_equal(s, InputString.new([], true))
    assert_not_equal(s, InputString.new(['a'], true))
    assert_not_equal(s, InputString.new([], nil))

    s = InputString.new([], nil)
    assert_equal(s, InputString.new([], nil))
    assert_equal(s, InputString.new('', nil))
    assert_not_equal(s, InputString.new([], true))
    assert_not_equal(s, InputString.new(['a'], true))
    assert_not_equal(s, InputString.new([], false))
    assert_not_equal(s, InputString.new(['a'], false))
      
    s = InputString.new('a b a b', true)
    assert_equal(s, InputString.new("a b \n a b", true))
    assert_equal(s, InputString.new(['a', 'b', 'a', 'b'], true))
    assert_not_equal(s, InputString.new(['a', 'b', 'a', 'b'], false))
    assert_not_equal(s, InputString.new(['a', 'b', 'a'], true))
    assert_not_equal(s, InputString.new([], true))
  end
  
  def test_equality_2
    assert InputString.new('+', true)==InputString.new('+', true)
    assert InputString.new('+ a b', true)==InputString.new('+ a b', true)
    
    strings = [InputString.new('+', true), InputString.new('+', true)]
    assert_equal 1, strings.uniq.size
  end
  
  # Tests that input string accept other objects than strings as symbols
  def test_input_string_accept_any_symbol_object
    s = InputString.new([1, 2], true)
    assert_equal(2, s.size)
    assert_equal([1, 2], s.symbols)
  end
  
  def test_input_string_may_be_used_as_hash_key
    str = InputString.new('a b a b', true)
    neg = InputString.new('a b a b', false)
    unl = InputString.new('a b a b', nil)
    h = {}
    h[str] = 1
    assert h.has_key?(str)
    assert_equal 1, h[str]
    assert !h.has_key?(neg)
    assert !h.has_key?(unl)
    h[neg] = 2
    assert h.has_key?(str)
    assert_equal 1, h[str]
    assert h.has_key?(neg)
    assert_equal 2, h[neg]
    assert !h.has_key?(unl)
    h[unl] = 3
    assert h.has_key?(str)
    assert_equal 1, h[str]
    assert h.has_key?(neg)
    assert_equal 2, h[neg]
    assert h.has_key?(unl)
    assert_equal 3, h[unl]
  end
  
end # class InputStringTest

end # module Stamina

