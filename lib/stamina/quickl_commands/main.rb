module Stamina
  module QuicklCommands
    #
    # Stamina - A Ruby Automaton & Induction Toolkit
    #
    # SYNOPSIS
    #   #{program_name} [--version] [--help] COMMAND [cmd opts] ARGS...
    #
    # OPTIONS
    # #{summarized_options}
    #
    # COMMANDS
    # #{summarized_subcommands}
    #
    # See '#{program_name} help COMMAND' for more information on a specific command.
    #
    class Main < ::Quickl::Delegator(__FILE__, __LINE__)

      # Install options
      options do |opt|
        
        # Show the help and exit
        opt.on_tail("--help", "Show help") do
          raise Quickl::Help
        end

        # Show version and exit
        opt.on_tail("--version", "Show version") do
          raise Quickl::Exit, "#{program_name} #{VERSION} (c) 2010-2011, Bernard Lambeau"
        end

      end

    end # class Main
  end # module QuicklCommands
end # module Stamina
require 'stamina/quickl_commands/help'
require 'stamina/quickl_commands/metrics'
require 'stamina/quickl_commands/abbadingo_dfa'
require 'stamina/quickl_commands/abbadingo_samples'

