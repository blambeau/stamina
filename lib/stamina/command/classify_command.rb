require 'stamina/command/stamina_command'
require 'stamina/induction/rpni'
module Stamina
  module Command
    
    # Implementation of the classify command line tool
    class ClassifyCommand < StaminaCommand
    
      # Creates a score command instance
      def initialize
        super("classify", "[options] sample.adl automaton.adl",
              "Classify a sample using an automaton, both expressed in ADL")
      end
      
      # Installs additional options
      def options
        super do |opt|
          opt.on("-o", "--output=OUTPUT",
                 "Flush classification signature in output file") do |value|
            assert_writable_file(value)
            @output_file = value
          end
        end
      end
      
      # Sets the sample file
      def sample_file=(file)
        assert_readable_file(file)
        @sample = Stamina::ADL.parse_sample_file(file)
      rescue Stamina::ADL::ParseError
        raise ArgumentError, "#{file} is not a valid ADL sample file"
      end
      
      # Sets the automaton file
      def automaton_file=(file)
        assert_readable_file(file)
        @automaton = Stamina::ADL.parse_automaton_file(file)
      rescue Stamina::ADL::ParseError
        raise ArgumentError, "#{file} is not a valid ADL automaton file"
      end
      
      # Executes the command
      def main(argv)
        parse(argv, :sample_file, :automaton_file)
        if @output_file 
          File.open(@output_file, 'w') do |file|
            file << @automaton.signature(@sample) << "\n"
          end
        else
          STDOUT << @automaton.signature(@sample) << "\n"
        end          
      end
      
    end # class ClassifyCommand
    
  end # module Command
end # module Stamina