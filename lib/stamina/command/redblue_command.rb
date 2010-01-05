require 'stamina/command/stamina_command'
require 'stamina/induction/redblue'
module Stamina
  module Command
    
    # Implementation of the redblue command line tool
    class RedBlueCommand < StaminaCommand
    
      # Creates a score command instance
      def initialize
        super("redblue", "[options] sample.adl",
              "Executes RedBlue (Regular Positive and Negative Inference) on a ADL sample and\n"\
              "flushes the induced DFA on the standard output in ADL format as well")
      end
      
      # Installs additional options
      def options
        super do |opt|
          opt.on("-v", "--verbose", "Verbose mode") do
            @verbose = true
          end
          opt.on("-o", "--output=OUTPUT",
                 "Flush induced DFA in output file") do |value|
            assert_writable_file(value)
            @output_file = value
          end
        end
      end
      
      # Sets the sample file
      def sample_file=(file)
        assert_readable_file(file)
        puts "Parsing sample and building PTA" if @verbose
        @sample = Stamina::ADL.parse_sample_file(file)
      rescue Stamina::ADL::ParseError
        raise ArgumentError, "#{file} is not a valid ADL sample file"
      end
      
      # Executes the command
      def main(argv)
        parse(argv, :sample_file)
        t1 = Time.now
        dfa = Stamina::Induction::RedBlue.execute(@sample, {:verbose => @verbose})
        t2 = Time.now
        if @output_file 
          File.open(@output_file, 'w') do |file|
            Stamina::ADL.print_automaton(dfa, file)
          end
        else
          Stamina::ADL.print_automaton(dfa, STDOUT)
        end          
        puts "Executed in #{t2-t1} sec" if @verbose
      end
      
    end # class ScoreCommand
    
  end # module Command
end # module Stamina