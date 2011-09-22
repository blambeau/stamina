require 'stamina'
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
require 'stamina/command/robustness'
require 'stamina/command/help'
require 'stamina/command/adl2dot'
require 'stamina/command/metrics'
require 'stamina/command/classify'
require 'stamina/command/score'
require 'stamina/command/abbadingo_dfa'
require 'stamina/command/abbadingo_samples'
require 'stamina/command/infer'
require 'stamina/command/run'

