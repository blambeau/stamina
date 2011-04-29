module Stamina
  module QuicklCommands
    class Main
      # 
      # Regular Positive and Negative Inference (induces a DFA from a training sample)
      #
      # SYNOPSIS
      #   #{program_name} #{command_name} sample.adl
      #
      # OPTIONS
      # #{summarized_options}
      #
      class Rpni < Quickl::Command(__FILE__, __LINE__)
        include Robustness
        
        attr_accessor :verbose
        attr_accessor :output_file

        # Install options
        options do |opt|
        
          @verbose = true
          opt.on("-v", "--[no-]verbose", "Verbose mode") do |x|
            @verbose = x
          end

          @output_file = nil
          opt.on("-o", "--output=OUTPUT",
                 "Flush induced DFA in output file") do |value|
            assert_writable_file(value)
            @output_file = value
          end

        end # options

        # Command execution
        def execute(args)
          raise Quickl::Help unless args.size == 1
        
          # Parses the sample
          puts "Parsing sample..." if verbose
          sample = Stamina::ADL.parse_sample_file(assert_readable_file(args.first))

          # Induce the DFA
          t1 = Time.now
          dfa = Stamina::Induction::RPNI.execute(sample, {:verbose => verbose})
          t2 = Time.now

          # Flush result
          if @output_file 
            File.open(@output_file, 'w') do |file|
              Stamina::ADL.print_automaton(dfa, file)
            end
          else
            Stamina::ADL.print_automaton(dfa, $stdout)
          end

          # Display information
          puts "Executed in #{t2-t1} sec." if verbose
        end
        
      end # class Rpni
    end # class Main
  end # module QuicklCommands
end # module Stamina

