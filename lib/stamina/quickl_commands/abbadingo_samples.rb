module Stamina
  module QuicklCommands
    class Main
      # 
      # Generates samples Abbadingo's protocol
      #
      # SYNOPSIS
      #   #{program_name} #{command_name} target.adl
      #
      # OPTIONS
      # #{summarized_options}
      #
      class AbbadingoSamples < Quickl::Command(__FILE__, __LINE__)
        
        # Install options
        options do |opt|
        
        end # options

        # Command execution
        def execute(args)
          raise Quickl::Help unless args.size == 1

          # Loads the target automaton
          target_file = args.first
          basename = File.basename(target_file, '.adl')
          dirname = File.dirname(target_file)
          target = Stamina::ADL::parse_automaton_file(target_file)

          require 'stamina/abbadingo'
          training, test = Stamina::Abbadingo::RandomSample.execute(target)

          # Flush results aside the target automaton file
          Stamina::ADL::print_sample_in_file(training, File.join(dirname, "#{basename}-training.adl"))
          Stamina::ADL::print_sample_in_file(test,     File.join(dirname, "#{basename}-test.adl"))
        end
        
      end # class AbbadingoSamples
    end # class Main
  end # module QuicklCommands
end # module Stamina

