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
        
        # Size of the target automaton
        attr_accessor :size

        # Tolerance on the size
        attr_accessor :size_tolerance

        # Tolerance on the automaton depth
        attr_accessor :depth_tolerance

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

        end # options

        def accept?(dfa)
          (size_tolerance.nil?  || (size - dfa.state_count).abs <= size_tolerance) &&
          (depth_tolerance.nil? || ((2*Math.log2(size)-2) - dfa.depth).abs <= depth_tolerance)
        end

        # Command execution
        def execute(args)
          require 'stamina/abbadingo'
          randomizer = Stamina::Abbadingo::RandomDFA.new(size)
          begin
            dfa = randomizer.execute
          end until accept?(dfa)
          puts dfa.to_adl
        end
        
      end # class AbbadingoDFA
    end # class Main
  end # module QuicklCommands
end # module Stamina

