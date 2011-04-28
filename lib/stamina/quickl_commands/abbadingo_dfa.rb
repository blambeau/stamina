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
        
        attr_accessor :size

        # Install options
        options do |opt|
        
          # Show the help and exit
          @size = 64
          opt.on("--size=X", "Sets the size of the automaton to generate") do |x|
            @size = x
          end

        end # options

        # Command execution
        def execute(args)
          require 'stamina/abbadingo'
          puts Stamina::Abbadingo::RandomDFA.new(size).execute.to_adl
        end
        
      end # class AbbadingoDFA
    end # class Main
  end # module QuicklCommands
end # module Stamina

