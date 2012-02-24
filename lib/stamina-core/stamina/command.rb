module Stamina
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
  class Command < ::Quickl::Delegator(__FILE__, __LINE__)

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

  end # class Command
end # module Stamina
require_relative 'command/robustness'
require_relative 'command/help'
require_relative 'command/adl2dot'
require_relative 'command/run'