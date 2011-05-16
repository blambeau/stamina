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
      
      attr_reader :output_format

      # Install options
      options do |opt|
      
        @output_file = nil
        opt.on("-o", "--output=OUTPUT",
               "Flush result output file") do |value|
          @output_file = assert_writable_file(value)
        end
       
        @output_format = "dot"
        opt.on("-g", "--gif",
               "Generates a gif file instead of a dot one") do
          @output_format = "gif"
        end

        opt.on("--png",
               "Generates a png file instead of a dot one") do
          @output_format = "png"
        end

      end # options

      def output_file(infile)
        @output_file || "#{File.basename(infile || 'stdin.adl', '.adl')}.#{output_format}"
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

        begin
          automaton = Stamina::ADL::parse_automaton(input)
        rescue ADL::ParseError 
          sample = Stamina::ADL::parse_sample(input)
          automaton = sample.to_pta
        end

        # create a file for the dot output
        if output_format == 'dot'
          dotfile = output_file(args.first)
        else
          require 'tempfile'
          dotfile = Tempfile.new("stamina").path
        end
        
        # Flush automaton inside it
        File.open(dotfile, 'w') do |f|
          f << automaton.to_dot
        end
        
        # if gif output, use dot to convert it
        unless output_format == 'dot'
          `dot -T#{output_format} -o #{output_file(args.first)} #{dotfile}` 
        end
      end
      
    end # class Adl2dot
  end # class Command
end # module Stamina

