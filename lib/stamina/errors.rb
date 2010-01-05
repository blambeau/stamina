module Stamina
  
  # Main class of all stamina errors.
  class StaminaError < StandardError; end
  
  # Raised by samples implementations and other induction algorithms
  # when a sample is inconsistent (same string labeled as being both 
  # positive and negative)
  class InconsistencyError < StaminaError; end
  
  # Specific errors of the ADL module.
  module ADL
    
    # Raised by the ADL module when an automaton, string or sample
    # format is violated at parsing time.
    class ParseError < StaminaError; end
  
  end

end # module Stamina