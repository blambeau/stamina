module Stamina
  module QuicklCommands
    class Main
      # 
      # Prints metrics about an automaton or sample
      #
      # SYNOPSIS
      #   #{program_name} #{command_name} [file.adl]
      #
      # OPTIONS
      # #{summarized_options}
      #
      class Metrics < Quickl::Command(__FILE__, __LINE__)
        
        # Install options
        options do |opt|
        
        end # options

        # Command execution
        def execute(args)
          raise Quickl::Help unless args.size <= 1

          # Loads the target automaton
          input = (args.size == 1 ? File.read(args.first) : $stdin.readlines.join("\n"))
          begin
            target = Stamina::ADL::parse_automaton(input)
            puts "Alphabet size:   #{target.alphabet_size}"
            puts "State count:     #{target.state_count}"
            puts "Edge count:      #{target.edge_count}"
            puts "Degree (avg):    #{target.avg_degree}"
            puts "Accepting ratio: #{target.accepting_ratio}"
            puts "Depth:           #{target.depth}"
          rescue ADL::ParseError 
            sample = Stamina::ADL::parse_sample(input)
            puts "Size:     #{sample.size}"
            puts "Positive: #{sample.positive_count} (#{sample.positive_count.to_f / sample.size})"
            puts "Negative: #{sample.negative_count} (#{sample.negative_count.to_f / sample.size})"
          end
        end
        
      end # class Metrics
    end # class Main
  end # module QuicklCommands
end # module Stamina

