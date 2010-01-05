require 'stamina/command/stamina_command'
module Stamina
  module Command
    
    # Implementation of the adl2dot command line tool
    class Adl2DotCommand < StaminaCommand
    
      # Gif output instead of dot?
      attr_reader :gif_output
    
      # Creates a score command instance
      def initialize
        super("adl2dot", "[options] automaton.adl",
              "Prints an automaton expressed in ADL in dot (or gif) format")
        @gif_output = false
      end
      
      # Installs additional options
      def options
        super do |opt|
          opt.on("-o", "--output=OUTPUT",
                 "Flush result output file") do |value|
            assert_writable_file(value)
            @output_file = value
          end
          opt.on("-g", "--gif",
                 "Generates a gif file instead of a dot one") do
            @gif_output = true
          end
        end
      end
      
      # Sets the automaton file
      def automaton_file=(file)
        assert_readable_file(file)
        @automaton_file = file
        @automaton = Stamina::ADL.parse_automaton_file(file)
      rescue Stamina::ADL::ParseError
        raise ArgumentError, "#{file} is not a valid ADL automaton file"
      end
      
      # Returns the output file to use
      def output_file
        @output_file || "#{File.basename(@automaton_file, '.adl')}.#{gif_output ? 'gif' : 'dot'}"
      end
      
      # Executes the command
      def main(argv)
        parse(argv, :automaton_file)
        
        # create a file for the dot output
        if gif_output
          require 'tempfile'
          dotfile = Tempfile.new("stamina").path
        else
          dotfile = output_file
        end
        
        # Flush automaton inside it
        File.open(dotfile, 'w') do |f|
          f << Stamina::ADL.parse_automaton_file(@automaton_file).to_dot
        end
        
        # if gif output, use dot to convert it
        if gif_output
          `dot -Tgif -o #{output_file} #{dotfile}` 
        end
      end
      
    end # class ScoreCommand
    
  end # module Command
end # module Stamina