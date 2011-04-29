module Stamina
  class Command
    # 
    # Scores the labelling of a sample by an automaton
    #
    # SYNOPSIS
    #   #{program_name} #{command_name} sample.adl automaton.adl
    #
    # OPTIONS
    # #{summarized_options}
    #
    class Score < Quickl::Command(__FILE__, __LINE__)
      include Robustness

      # Install options
      options do |opt|

      end # options

      # Command execution
      def execute(args)
        raise Quickl::Help unless args.size == 2
        sample    = Stamina::ADL::parse_sample_file assert_readable_file(args.first)
        automaton = Stamina::ADL::parse_automaton_file assert_readable_file(args.last)

        classified_as = automaton.signature(sample)
        reference = sample.signature
        scoring = Scoring.scoring(classified_as, reference)
        puts scoring.to_s
      end
      
    end # class Score
  end # class Command
end # module Stamina

