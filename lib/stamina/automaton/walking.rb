module Stamina
  class Automaton
    #
    # Provides useful automaton walking methods. This module is automatically 
    # included in Automaton and is not intended to be used directly.
    #
    # == Examples
    #     # Building an automaton for the regular language a(ba)*
    #     s0, s1 = nil
    #     fa = Automaton.new do
    #       s0 = add_state(:initial => true)
    #       s1 = add_state(:accepting => true)
    #       connect(0,1,'a')
    #       connect(1,0,'b')
    #     end
    #
    #     # some examples with reached
    #     fa.dfa_reached('? a b')      # -> s0     dfa variant method
    #     fa.dfa_reached('? a a')      # -> nil
    #     fa.dfa_reached('? b a', s1)  # -> s1     from an explicit init state
    #
    #     fa.reached('? a b')          # -> [s0]   generic method on automaton
    #     fa.reached('? a a')          # -> []
    #     fa.reached('? b a', s1)      # -> [s1]
    #
    #     # some examples with split (the most powerful one!)  
    #     fa.dfa_split('? a b a b')    # [['a','b','a','b'], s0, []]
    #     fa.dfa_split('? a b b a')    # [['a','b'], s0, ['b','a']]
    #  
    #     fa.split('? a b a b')        # [['a','b','a','b'], [s0], []]
    #     fa.split('? a b b a')        # [['a','b'], [s0], ['b','a']]
    #
    #     # All of this works on non-deterministic automata as well (and epsilon
    #     # symbols are taken into account), but you'll probably need to read
    #     # the following section to master the power of this module in this case!
    #
    # == Using this module
    # This section fully details the design choices that has been made for the 
    # implementation of the Walking module used by Stamina on Automaton. It is provided
    # because Walking is one of the core classes of Stamina, that probably all 
    # users (and contributors) will use. Walking usage is really user-friendly, 
    # so <b>you are normally not required</b> to read this section in the first 
    # place ! Read it only if of interest for you, or if you experiment unexpected
    # results.
    #
    # Methods defined by this module respect common conventions that you must be
    # aware of:
    #
    # === Generic methods vs. dfa variants
    # The convention is simple: methods whose name starts with 'dfa_' are expected
    # to be used on deterministic automata only (that is, automata answering _true_
    # to the deterministic? method invocation). We refer to those methods as 
    # 'dfa variants'. Strange results may occur if invoked on non-deterministic 
    # automata. Other methods are called 'generic methods' and can be used on any
    # automaton. Generic methods and dfa variants sometimes use different conventions
    # according to arguments and returned values, as explained below.
    #
    # === Argument conventions
    # - all methods taking a _symbol_ argument expect it to be a valid instance of 
    #   the class used for representing input symbols on edges of your automaton 
    #   (that is, the mark you've installed under :symbol key on the edge, see 
    #   Automaton documentation for details).
    # - all methods taking an _input_ argument support the following objects for it:
    #   - InputString instance: an real input string typically coming from a Sample.
    #   - Array of symbols: where by symbol, we mean an input symbol as explained
    #     above (and not a Ruby Symbol instance). The array is never modified by the
    #     methods, so that you don't have to worry about where this array comes from.
    #   - String (a real Ruby one): in this case, the input is expected to be an ADL
    #     input string, which is parsed using ADL::parse_string. Note that 'a b a b'
    #     is NOT a valid ADL input string, so that you typically have to use the '?'
    #     sign to indicate that the tested string is basically unlabeled.
    # - all methods taking a _from_ argument support the following objects for it:
    #   - ommited: _from_ is interpreted as the set of initial states by generic
    #     methods and the last rule applies. _from_ is interpreted as the unique initial 
    #     state of the deterministic automaton by dfa method variants (<tt>dfa_xxx</tt>),
    #     and the third rule applies.
    #   - Integer: _from_ is interpreted as a state index, and the next rule applies
    #     on the index-th state of the automaton. 
    #   - State: _from_ is interpreted by the generic methods as a singleton set 
    #     containing the state and the last rule applies. Deterministic method
    #     variants interpret it as the start state from which the walk must start.
    #     In this case, they always return a State instance (or _nil_) instead of
    #     an array of states.
    #   - Array: _from_ is interpreted as a set of states (duplicates are supported
    #     so it's actually a bag) from which the walk must start. Indexes of states
    #     are also supported, see Automaton documentation about indexes.
    #
    # === Returned value conventions
    # Moreover, (unless stated explicitely) all methods returning states as (part of) 
    # their returned value respect the following _return_ conventions (which somewhat 
    # summarizes the _from_ conventions above):
    # - generic methods *always* return an array of states (without duplicates) which
    #   can be modified. This array is *never* sorted by state index. To insist:
    #   even when invoked on a deterministic automaton with a State argument as 
    #   _from_, they will return an array of states as show by the code excerpt 
    #   below. Lastly, the returned value is *never* _nil_, but an empty array may
    #   be returned when it makes sense (no reached states for example).
    #  
    #       fa = Automaton.new do ... end     # build a(ba)* automaton 
    #       s0 = fa.initial_state
    #       fa.reached('? a b a b', s0)         # returns [s0], not s0 !
    #
    # - dfa variant methods respond to your query using the same language as you:
    #   if _from_ is ommitted, is a State or an Integer, the the result will be a 
    #   single State instance, or _nil_ if it makes sense (no reached state for 
    #   example). Otherwise, they behaves exactly as generic methods (*always* return 
    #   an array of states, ...)
    #
    # === Epsilon symbol aware methods
    # Stamina does not allow epsilon symbols on deterministic automata; thus, this 
    # subsection only applies to generic methods.
    #
    # Methods documented as 'epsilon aware' (almost all generic methods) *always* 
    # take epsilon symbols into account in their computations (Stamina uses _nil_ as
    # epsilon symbol, by convention), in a natural way. For example:
    #
    #       fa = Automaton.new do ... end    # build a non-deterministic automaton
    #                                        # with epsilon symbols 
    #
    #       # the line below computes the set of reached states
    #       # (from the set of initial states) by walking the dfa
    #       # with a string.
    #       #
    #       # The actual computation is in fact the set of reached
    #       # states with the string (regex) 'eps* a eps* b eps*', 
    #       # where eps is the epsilon symbol.
    #       reached = fa.reached('? a b')
    #
    # == Detailed API
    module Walking
  
      #
      # Returns reachable states from _from_ states with an input _symbol_. This 
      # method is not epsilon symbol aware.
      #
      def step(from, symbol)
        from = walking_to_from(from)
        from.collect{|s| s.step(symbol)}.flatten.uniq
      end
  
      #
      # Returns the state reached from _from_ states with an input _symbol_. Returns
      # nil or the empty array (according to _from_ conventions) if no state can be
      # reached with the given symbol. 
      #
      def dfa_step(from, symbol)
        step = walking_to_from(from).collect{|s| s.dfa_step(symbol)}.flatten.uniq
        walking_to_dfa_result(step, from)
      end
        
      #
      # Computes an array representing the set of states that can be reached from
      # _from_ states with the given input _symbol_.
      #
      # This method is epsilon symbol aware (represented with nil) on non
      # deterministic automata, meaning that it actually computes the set of 
      # reachable states through strings respecting the <tt>eps* symbol eps*</tt> 
      # regular expression, where eps is the epsilon symbol.
      #
      def delta(from, symbol)
        walking_to_from(from).collect{|s| s.delta(symbol)}.flatten.uniq
      end
    
      #
      # Returns the target state (or the target states, according to _from_ 
      # conventions) that can be reached from _from_ states with a given input
      # _symbol_. Returns nil (or an empty array, according to the same conventions) 
      # if no such state exists.
      #
      def dfa_delta(from, symbol) 
        delta = walking_to_from(from).collect{|s| s.dfa_delta(symbol)}.flatten.uniq
        walking_to_dfa_result(delta, from)
      end
    
      #
      # Splits a given input and returns a triplet <tt>[parsed,reached,remaining]</tt>
      # where _parsed_ is an array of parsed symbols, _reached_ is the set of reached
      # states with the _parsed_ input string and _remaining_ is an array of symbols
      # with the unparsable part of the string. This method is epsilon symbol aware. 
      #
      # By construction, the following properties are verified:
      # - <tt>parsed + remaining == input</tt> (assuming input is an array of symbols),
      #   which means that atring concatenation of parsed and remaining symbols is
      #   is the input string.
      # - <tt>reached.empty? == false</tt>, because at least initial states (or 
      #   _from_ if provided) are reached.
      # - <tt>remaining.empty? == parses?(input,from)</tt>, meaning that the automaton
      #   parses the whole input if there is no remaining symol.
      # - <tt>delta(reached, remaining[0]).empty? unless remaining.empty?</tt>, 
      #   which express the splitting stop condition: splitting continues while at
      #   least one state can be reached with the next symbol.
      #
      def split(input, from=nil, sort=false)
        if deterministic?
          parsed, reached, remaining = dfa_split(input, from)
          [parsed, walking_from_dfa_to_nfa_result(reached), remaining]
        else
          # the three elements of the triplet
          parsed = []
          reached = walking_to_from(from)
          remaining = walking_to_modifiable_symbols(input)
      
          # walk now
          until remaining.empty?
            symb = remaining[0]
            next_reached = delta(reached, symb)
        
            # stop it if no reached state
            break if next_reached.empty? 
        
            # otherwise, update triplet
            parsed << remaining.shift
            reached = next_reached
          end
          reached.sort! if sort
          [parsed, reached, remaining]
        end
      end

      # Same as split, respecting dfa conventions.
      def dfa_split(input, from=nil)
        # the three elements of the triplet
        parsed = []
        reached = walking_to_from(from)
        remaining = walking_to_modifiable_symbols(input)
    
        # walk now
        until remaining.empty?
          symb = remaining[0]
          next_reached = dfa_delta(reached, symb)
      
          # stop it if no reached state
          break if next_reached.nil? or next_reached.empty? 
      
          # otherwise, update triplet
          parsed << remaining.shift
          reached = next_reached
        end
        [parsed, walking_to_dfa_result(reached, from), remaining]
      end
  
      #
      # Walks the automaton with an input string, starting at states _from_, 
      # collects the set of all reached states and returns it. Unlike split, 
      # <b>returned array is empty if the string is not parsable by the automaton</b>. 
      # This method is epsilon symbol aware.
      #
      def reached(input, from=nil)
        parsed, reached, remaining = split(input, from)
        remaining.empty? ? reached : []
      end
  
      # Same as reached, respecting dfa conventions.
      def dfa_reached(input, from=nil)
        walking_to_dfa_result(reached(input,from),from)
      end
  
      #
      # Checks if the automaton is able to parse an input string. Returns true if 
      # at least one state can be reached, false otherwise. Unlike accepts?, the 
      # labeling of the reached state does not count.
      #
      def parses?(input, from=nil)
        not(reached(input,from).empty?)
      end
  
      #
      # Checks if the automaton accepts an input string. Returns true if at least 
      # one accepting state can be reached, false otherwise.
      #
      def accepts?(input, from=nil)
        not reached(input,from).select{|s| s.accepting? and not s.error?}.empty?
      end

      #
      # Checks if the automaton rejects an input string. Returns true if no 
      # accepting state can be reached, false otherwise.
      #
      def rejects?(input, from=nil)
        not(accepts?(input, from))
      end
    
      # Returns '1' if the string is accepted by the automaton,
      # '0' otherwise.
      def label_of(str)
        accepts?(str) ? '1' : '0'
      end
      
      ### protected section ########################################################
      protected
  
      #
      # Converts an input to a modifiable array of symbols.
      #
      # If _input_ is an array, it is simply duplicated. If an InputString, 
      # InputString#symbols is invoked and result is duplicated. If _input_ is a
      # ruby String, it is split using <tt>input.split(' ')</tt>. Raises an 
      # ArgumentError otherwise.  
      # 
      def walking_to_modifiable_symbols(input)
        case input
          when Array
            input.dup
          when InputString
            input.symbols.dup
          when String
            ADL::parse_string(input).symbols.dup
          else
            raise(ArgumentError,
                  "#{input} cannot be converted to a array of symbols", caller)
        end
      end
  
      # Implements _from_ conventions.
      def walking_to_from(from)
        return initial_states if from.nil?
        Array===from ? from.collect{|s| to_state(s)} : [to_state(from)]
      end
  
      # Implements _return_ conventions of dfa_xxx methods.
      def walking_to_dfa_result(result, from)
        result.compact! # methods are allowed to return [nil] 
        Array===from ? result : (result.empty? ? nil : result[0])
      end

      # Implements _return_ conventions of standard methods that uses dfa_xxx ones.
      def walking_from_dfa_to_nfa_result(result)
        Array===result ? result : (result.nil? ? [] : [result]) 
      end
  
    end # end Walking
    include Stamina::Automaton::Walking
    include Stamina::Classifier
  end # class Automaton
end # end Stamina

