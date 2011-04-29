module Stamina
  class Command
    # 
    # Prints an automaton expressed in ADL in dot (or gif) format
    #
    # SYNOPSIS
    #   #{program_name} #{command_name} automaton.adl
    #
    # OPTIONS
    # #{summarized_options}
    #
    class Adl2dot < Quickl::Command(__FILE__, __LINE__)
      include Robustness
      
      attr_reader :gif_output

      # Install options
      options do |opt|
      
        @output_file = nil
        opt.on("-o", "--output=OUTPUT",
               "Flush result output file") do |value|
          @output_file = assert_writable_file(value)
        end

        opt.on("-g", "--gif",
               "Generates a gif file instead of a dot one") do
          @gif_output = true
        end

      end # options

      def output_file(infile)
        @output_file || "#{File.basename(infile || 'stdin.adl', '.adl')}.#{gif_output ? 'gif' : 'dot'}"
      end

      # Command execution
      def execute(args)
        raise Quickl::Help unless args.size <= 1

        # Loads the target automaton
        input = if args.size == 1
          File.read assert_readable_file(args.first)
        else
          $stdin.readlines.join("\n")
        end
        automaton = Stamina::ADL::parse_automaton(input)

        # create a file for the dot output
        if gif_output
          require 'tempfile'
          dotfile = Tempfile.new("stamina").path
        else
          dotfile = output_file(args.first)
        end
        
        # Flush automaton inside it
        File.open(dotfile, 'w') do |f|
          f << automaton.to_dot
        end
        
        # if gif output, use dot to convert it
        if gif_output
          `dot -Tgif -o #{output_file(args.first)} #{dotfile}` 
        end
      end
      
    end # class Adl2dot
  end # class Command
end # module Stamina

