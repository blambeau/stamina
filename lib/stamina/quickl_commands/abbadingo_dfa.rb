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

        # Install options
        options do |opt|
        
          @size = 64
          opt.on("--size=X", "Sets the size of the automaton to generate") do |x|
            @size = x.to_i
          end

          @size_tolerance = nil
          opt.on("--size-tolerance[=X]", Float, "Sets the tolerance on automaton size, in percentage") do |x|
            @size_tolerance = x.to_f
          end

        end # options

        def accept?(dfa)
          size_tolerance.nil? || (size - dfa.state_count).abs <= (size.to_f*size_tolerance)
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

