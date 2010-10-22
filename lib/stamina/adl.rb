module Stamina
  #
  # Automaton Description Language module. This module provides parsing and 
  # printing methods for automata and samples. Documentation of the file format
  # used for an automaton is given in parse_automaton; file format for samples is
  # documented in parse_sample.
  # 
  # Methods of this module are not intended to be included by a class but invoked
  # on the module instead:
  #
  #   begin 
  #     dfa = Stamina::ADL.parse_automaton_file("my_automaton.adl")
  #   rescue ADL::ParseError => ex
  #     puts "Oops, the ADL automaton file seems corrupted..."
  #   end
  #
  # == Detailed API
  module ADL
  
    #################################################################################
    # Automaton Section                                                             #
    #################################################################################
  
    #
    # Parses a given automaton description and returns an Automaton instance.
    #
    # Raises:
    # - ArgumentError unless _descr_ is an IO object or a String.
    # - ADL::ParseError if the ADL automaton format is not respected. 
    #
    # ADL provides a really simple grammar to describe automata. Here is a succint
    # example (full documentation of the ADL automaton grammar can be found in
    # the self-documenting example/adl/automaton.adl file).  
    #     
    #    # Some header comments: tool which has generated this automaton,
    #    # maybe a date or other tool options ...
    #    # here: 'this automaton accepts the a(ba)* regular language'
    #    2 2
    #    0 true false
    #    1 false true
    #    0 1 a
    #    1 0 b
    #
    def self.parse_automaton(descr)
      automaton = nil
      ADL::to_io(descr) do |io|
        state_count, edge_count = nil, nil
        state_read, edge_read = 0, 0
        states = {}
        mode = :header
  
        automaton = Automaton.new do |fa|
          # parse each description line
          line_number = 1
          io.each_line do |l|
            index = l.index('#')
            l = l[0,index] if index
            l = l.strip
            next if l.empty? or l[0,1]=='#'
          
            case mode
            when :header    
              # looking for |state_count edge_count| 
              raise(ADL::ParseError,
                    "Parse error line #{line_number}: 'state_count edge_count' expected, "\
                    "'#{l}' found.") unless /^(\d+)\s+(\d+)$/ =~ l
              state_count, edge_count = $1.to_i, $2.to_i
              mode = :states
            
            when :states
              # looking for |number initial accepting|
              raise(ADL::ParseError,
                    "Parse error line #{line_number}: state definition expected, "\
                    "'#{l}' found.") unless /^(\S+)\s+(true|false)\s+(true|false)$/ =~ l
              id, initial, accepting = $1, $2, $3
              initial, accepting = ("true"==initial), ("true"==accepting)
            
              state = fa.add_state(:initial => initial, :accepting => accepting)
              state[:name]=id.to_s
              states[id] = state
            
              state_read += 1
              mode = (edge_count==0 ? :end : :edges) if state_read==state_count
            
            when :edges
              # looking for |source target symbol|
              raise(ADL::ParseError,
                    "Parse error line #{line_number}: edge definition expected, "\
                    "'#{l}' found.") unless /^(\S+)\s+(\S+)\s+(\S+)$/ =~ l
              source, target, symbol = $1, $2, $3
              raise(ADL::ParseError,
                    "Parse error line #{line_number}: no such state #{source}") \
                    unless states[source]
              raise(ADL::ParseError,
                    "Parse error line #{line_number}: no such state #{target}") \
                    unless states[target]
  
              fa.connect(states[source], states[target], {:symbol => symbol})
                                    
              edge_read += 1
              mode = :end if edge_read==edge_count
            
            when :end
              raise(ADL::ParseError,
                    "Parse error line #{line_number}: trailing data found '#{l}")
            
            end # case mode
          
            line_number += 1
          end
  
          raise(ADL::ParseError, "Parse error: #{state_count} states annouced, "\
                               "#{state_read} found.") if state_count != state_read
          raise(ADL::ParseError, "Parse error: #{edge_count} edges annouced, "\
                               "#{edge_read} found.") if edge_count != edge_read
        
        end # Automaton.new
      end
      return automaton
    end # def self.parse
  
    #
    # Parses an automaton file _f_.
    #
    # Shortcut for:
    #   File.open(f, 'r') do |io|
    #     Stamina::ADL.parse_automaton(io)
    #   end
    #
    def self.parse_automaton_file(f)
      automaton = nil
      File.open(f) do |file|
        automaton = ADL::parse_automaton(file)
      end
      automaton
    end
    
    #
    # Prints an automaton to a buffer (responding to <code>:&lt;&lt;</code>) in ADL 
    # format. Returns the buffer itself.
    #
    def self.print_automaton(fa, buffer="")
      buffer << "#{fa.state_count.to_s} #{fa.edge_count.to_s}" << "\n"
      fa.states.each do |s|
        buffer << "#{s.index.to_s} #{s.initial?} #{s.accepting?}" << "\n"
      end
      fa.edges.each do |e|
        buffer << "#{e.source.index.to_s} #{e.target.index.to_s} #{e.symbol.to_s}" << "\n"
      end
      buffer
    end
  
    #  
    # Prints an automaton to a file whose path is provided.
    #
    # Shortcut for:
    #   File.open(file, 'w') do |io|
    #     print_automaton(fa, io)
    #  end
    #
    def self.print_automaton_to_file(fa, file)
      File.open(file, 'w') do |io|
        print_automaton(fa, io)
      end
    end
    
    #################################################################################
    # String and Sample Section                                                     #
    #################################################################################
  
    #
    # Parses an input string _str_ and returns a InputString instance. Format of 
    # input strings is documented in parse_sample. _str_ is required to be a ruby 
    # String.
    #
    # Raises:
    # - ADL::ParseError if the ADL string format is not respected.
    #
    def self.parse_string(str)
      symbols = str.split(' ')
      case symbols[0]
        when '+'
          symbols.shift
          InputString.new symbols, true, false
        when '-'
          symbols.shift
          InputString.new symbols, false, false
        when '?'
          symbols.shift
          InputString.new symbols, nil, false
        else
          raise ADL::ParseError, "Invalid string format #{str}", caller
      end
    end
    
    #
    # Parses the sample provided by _descr_. When a block is provided, yields it with 
    # InputString instances and ignores the sample argument. Otherwise, fills the sample
    # (any object responding to <code><<</code>) with string, creating a fresh new
    # one (as a Sample instance) if sample is nil.
    #
    # ADL provides a really simple grammar to describe samples (here is a succint 
    # example, the full documentation of the sample grammar can be found in the
    # self-documenting example/adl/sample.adl file): 
    #
    #    #
    #    # Some header comments: tool which has generated this sample,
    #    # maybe a date or other tool options ...
    #    # here: 'this sample is caracteristic for the a(ba)* regular language'
    #    #
    #    # Positive, Negative, Unlabeled strings become with +, -, ?, respectively
    #    # Empty lines and lines becoming with # are simply ignored.
    #    #
    #    -
    #    + a
    #    - a b
    #    + a b a
    #
    # Raises:
    # - ArgumentError unless _descr_ argument is an IO object or a String.
    # - ADL::ParseError if the ADL sample format is not respected.
    # - InconsistencyError if the sample is not consistent (see Sample)
    #
    def self.parse_sample(descr, sample=nil)
      sample = Sample.new if (sample.nil? and not block_given?)
      ADL::to_io(descr) do |io|
        io.each_line do |l|
          l = l.strip
          next if l.empty? or l[0,1]=='#'
          if sample.nil? and block_given?
            yield parse_string(l)
          else
            sample << parse_string(l)
          end
        end
      end
      sample
    end
  
    #
    # Parses an automaton file _f_.
    #
    # Shortuct for:
    #   File.open(f) do |file|
    #      sample = ADL::parse_sample(file, sample)
    #   end
    #
    def self.parse_sample_file(f, sample=nil)
      File.open(f) do |file|
        sample = ADL::parse_sample(file, sample)
      end
      sample
    end
  
    #
    # Prints a sample in ADL format on a buffer. Sample argument is expected to be 
    # an object responding to each, yielding InputString instances. Buffer is expected
    # to be an object responding to <code><<</code>.
    #
    def self.print_sample(sample, buffer="")
      sample.each do |str|
        buffer << str.to_s << "\n"
      end
    end
  
    #
    # Prints a sample in a file.
    #
    # Shortcut for:
    #   File.open(file, 'w') do |io|
    #     print_sample(sample, f)
    #   end
    #
    def self.print_sample_in_file(sample, file)
      File.open(file, 'w') do |f|
        print_sample(sample, f)
      end
    end

    ### private section ##########################################################
    private
  
    #
    # Converts a parsable argument to an IO object or raises an ArgumentError.
    # 
    def self.to_io(descr)
      case descr
      when IO
        yield descr 
      when String
        yield StringIO.new(descr)
      else
        raise ArgumentError, "IO instance expected, #{descr.class} received", caller
      end
    end
  
  end # module ADL
end # module Stamina