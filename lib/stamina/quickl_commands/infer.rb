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
        attr_accessor :take
        attr_accessor :score
        attr_accessor :verbose
        attr_accessor :drop
        attr_accessor :output_file

        # Install options
        options do |opt|
        
          @algorithm = :rpni
          opt.on("--algorithm=X", "Sets the induction algorithm to use (rpni, bluefringe)") do |x|
            @algorithm = x.to_sym
          end

          @take = 1.0
          opt.on("--take=X", Float, "Take only X% of available strings") do |x|
            @take = x.to_f
            unless @take > 0.0 and @take <= 1.0
              raise Quickl::InvalidOption, "Invalid --take option: #{@take}"
            end 
          end

          @score = nil
          opt.on("--score=test.adl", "Add scoring information to metadata, using test.adl file") do |x|
            @score = assert_readable_file(x)
          end

          @verbose = true
          opt.on("-v", "--[no-]verbose", "Verbose mode") do |x|
            @verbose = x
          end

          @drop = false
          opt.on("-d", "--drop", "Drop result") do |x|
            @drop = x
          end

          @output_file = nil
          opt.on("-o", "--output=OUTPUT",
                 "Flush induced DFA in output file") do |value|
            @output_file = assert_writable_file(value)
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

        def load_sample(file)
          sample = Stamina::ADL.parse_sample_file(file)
          if @take != 1.0
            sampled = Stamina::Sample.new
            sample.each_positive{|s| sampled << s if Kernel.rand < @take}
            sample.each_negative{|s| sampled << s if Kernel.rand < @take}
            sample = sampled
          end
          sample
        end

        # Command execution
        def execute(args)
          raise Quickl::Help unless args.size == 1
        
          # Parses the sample
          $stderr << "Parsing sample...\n" if verbose
          sample = load_sample(assert_readable_file(args.first))

          # Induce the DFA
          dfa, tms = launch_induction(sample)

          # Flush result
          unless drop
            if output_file 
              File.open(output_file, 'w') do |file|
                Stamina::ADL.print_automaton(dfa, file)
              end
            else
              Stamina::ADL.print_automaton(dfa, $stdout)
            end
          end

          # build meta information
          meta = {:algorithm   => algorithm,
                  :sample      => File.basename(args.first),
                  :take        => take,
                  :sample_size => sample.size,
                  :positive_count => sample.positive_count,
                  :negative_count => sample.negative_count,
                  :real_time   => tms.real,
                  :total_time  => tms.total,
                  :user_time   => tms.utime + tms.cutime,
                  :system_time => tms.stime + tms.cstime}

          if score
            test = Stamina::ADL::parse_sample_file(score)
            classified_as = dfa.signature(test)
            reference = test.signature
            scoring = Scoring.scoring(classified_as, reference)
            meta.merge!(scoring.to_h)
          end

          # Display information
          puts meta.inspect
        end
        
      end # class Infer
    end # class Main
  end # module QuicklCommands
end # module Stamina

