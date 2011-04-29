module Stamina
  module QuicklCommands
    class Main
      # 
      # Generates a DFA following Abbadingo's protocol
      #
      # SYNOPSIS
      #   #{program_name} #{command_name}
      #
      # OPTIONS
      # #{summarized_options}
      #
      class AbbadingoDfa < Quickl::Command(__FILE__, __LINE__)
        include Robustness 

        # Size of the target automaton
        attr_accessor :size

        # Tolerance on the size
        attr_accessor :size_tolerance

        # Tolerance on the automaton depth
        attr_accessor :depth_tolerance

        # Where to flush the dfa
        attr_accessor :output_file

        # Install options
        options do |opt|
        
          @size = 64
          opt.on("--size=X", Integer, "Sets the size of the automaton to generate") do |x|
            @size = x
          end

          @size_tolerance = nil
          opt.on("--size-tolerance[=X]", Integer, "Sets the tolerance on automaton size (in number of states)") do |x|
            @size_tolerance = x
          end

          @depth_tolerance = 0
          opt.on("--depth-tolerance[=X]", Integer, "Sets the tolerance on expected automaton depth (in length, 0 by default)") do |x|
            @depth_tolerance = x
          end

          @output_file = nil
          opt.on("-o", "--output=OUTPUT",
                 "Flush DFA in output file") do |value|
            @output_file = assert_writable_file(value)
          end

        end # options

        def accept?(dfa)
          (size_tolerance.nil?  || (size - dfa.state_count).abs <= size_tolerance) &&
          (depth_tolerance.nil? || ((2*Math.log2(size)-2) - dfa.depth).abs <= depth_tolerance)
        end

        # Command execution
        def execute(args)
          require 'stamina/abbadingo'

          # generate it
          randomizer = Stamina::Abbadingo::RandomDFA.new(size)
          begin
            dfa = randomizer.execute
          end until accept?(dfa)

          # flush it
          if output_file 
            File.open(output_file, 'w') do |file|
              Stamina::ADL.print_automaton(dfa, file)
            end
          else
            Stamina::ADL.print_automaton(dfa, $stdout)
          end
        end
        
      end # class AbbadingoDFA
    end # class Main
  end # module QuicklCommands
end # module Stamina

