require 'stamina'
require 'optparse'
module Stamina
  module Command
    
    # Helper to create stamina commands
    class StaminaCommand
      
      # Command name
      attr_reader :name
      
      # Command description
      attr_reader :description
      
      # Command usage
      attr_reader :usage
      
      # Creates a command with a name, usage and description
      def initialize(name, usage, description)
        @name = name
        @usage = usage
        @description = description
      end
      
      # Creates options
      def options(&block)
        OptionParser.new do |opt|
          opt.program_name = name
          opt.version = Stamina::VERSION
          opt.release = nil
          opt.summary_indent = ' ' * 4
          banner = <<-EOF
            # usage: #{opt.program_name} #{usage}
            # #{description}
          EOF
          opt.banner = banner.gsub(/[ \t]+# /, "")
          block.call(opt) if block
          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end
      end
      
      # Prints usage (and optionnaly exits)
      def show_usage(and_exit=true)
        puts options
        Kernel.exit if and_exit
      end
      
      # Checks that a given file is readable or raises an ArgumentError
      def assert_readable_file(file)
        raise ArgumentError, "File #{file} does not exists" unless File.exists?(file)
        raise ArgumentError, "File #{file} cannot be read" unless File.readable?(file)
      end
      
      # Checks that a given file is writable or raises an ArgumentError
      def assert_writable_file(file)
        raise ArgumentError, "File #{file} cannot be written" \
          unless not(File.exists?(file)) or File.writable?(file)
      end
      
      # Parses arguments and install last argument as instance variables
      def parse(argv, *variables)
        rest = options.parse(argv)
        show_usage(true) unless rest.size==variables.size
        variables.each_with_index do |var,i|
          self.send("#{var}=".to_sym, rest[i])
        end
      rescue ArgumentError => ex
        puts ex.message
        puts
        show_usage(true)
      end
      
    end # class StaminaCommand
    
  end # module Command
end # module Stamina