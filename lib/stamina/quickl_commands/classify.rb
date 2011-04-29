module Stamina
  module QuicklCommands
    class Main
      # 
      # Classifies a sample thanks with an automaton
      #
      # SYNOPSIS
      #   #{program_name} #{command_name} sample.adl automaton.adl
      #
      # OPTIONS
      # #{summarized_options}
      #
      class Classify < Quickl::Command(__FILE__, __LINE__)
        include Robustness

        # Where to flush the output
        attr_accessor :output_file

        # Install options
        options do |opt|

          @output_file = nil
          opt.on("-o", "--output=OUTPUT",
                 "Flush classification signature in output file") do |value|
            assert_writable_file(value)
            @output_file = value
          end
        
        end # options

        # Command execution
        def execute(args)
          raise Quickl::Help unless args.size == 2
          sample    = Stamina::ADL::parse_sample_file assert_readable_file(args.first)
          automaton = Stamina::ADL::parse_automaton_file assert_readable_file(args.last)

          if of = output_file
            File.open(of, 'w'){|io| 
              io << automaton.signature(sample)
            }
          else
            $stdout << automaton.signature(sample)
          end
        end
        
      end # class Classify
    end # class Main
  end # module QuicklCommands
end # module Stamina

