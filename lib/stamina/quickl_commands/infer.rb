module Stamina
  module QuicklCommands
    class Main
      # 
      # Grammar inference, induces a DFA from a training sample using an 
      # chosen algorithm.
      #
      # SYNOPSIS
      #   #{program_name} #{command_name} sample.adl
      #
      # OPTIONS
      # #{summarized_options}
      #
      class Infer < Quickl::Command(__FILE__, __LINE__)
        include Robustness
        
        attr_accessor :algorithm
        attr_accessor :verbose
        attr_accessor :output_file

        # Install options
        options do |opt|
        
          @algorithm = :rpni
          opt.on("--algorithm=X", "Sets the induction algorithm to use (rpni, bluefringe)") do |x|
            @algorithm = x.to_sym
          end

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

        def launch_induction(sample)
          require 'benchmark'

          algo_clazz = case algorithm
            when :rpni
              Stamina::Induction::RPNI
            when :bluefringe
              Stamina::Induction::BlueFringe
            else
              raise Quickl::InvalidOption, "Unknown induction algorithm: #{algo}"
          end

          dfa, tms = nil, nil
          tms = Benchmark.measure do 
            dfa = algo_clazz.execute(sample, {:verbose => verbose})
          end
          [dfa, tms]
        end

        # Command execution
        def execute(args)
          raise Quickl::Help unless args.size == 1
        
          # Parses the sample
          puts "Parsing sample..." if verbose
          sample = Stamina::ADL.parse_sample_file(assert_readable_file(args.first))

          # Induce the DFA
          dfa, tms = launch_induction(sample)

          # Flush result
          if @output_file 
            File.open(@output_file, 'w') do |file|
              Stamina::ADL.print_automaton(dfa, file)
            end
          else
            Stamina::ADL.print_automaton(dfa, $stdout)
          end

          # Display information
          puts "Executed in #{tms.total} sec." if verbose
        end
        
      end # class Infer
    end # class Main
  end # module QuicklCommands
end # module Stamina

