module Stamina
  class Command
    #
    # Run a file with the Stamina Engine
    #
    # SYNOPSIS
    #   stamina #{command_name} FILE
    #
    # OPTIONS
    # #{summarized_options}
    #
    class Run < Quickl::Command(__FILE__, __LINE__)
      include Robustness

      attr_accessor :output
      attr_accessor :images

      # Install options
      options do |opt|

        @output = [:main]
        opt.on("--output=x,y,z", Array,
               "Output specified variables only") do |args|
          self.output = args.collect{|v| v.to_sym}
        end
        opt.on("--all",
               "Output all variables") do
          self.output = nil
        end

        @images = []
        opt.on('--gif') do
          self.images << :gif
        end
        opt.on('--png') do
          self.images << :png
        end
        opt.on('--dot') do
          self.images << :dot
        end

      end # options

      # Command execution
      def execute(args)
        raise Quickl::Help unless args.size == 1
        assert_readable_file(file = args.first)
        context = Stamina::Engine.execute(File.read(file), file)
        do_output(context, File.dirname(file))
        context
      end

      private

      def do_output(context, dir)
        self.output ||= context.vars
        self.output.each do |varname|
          varvalue = context[varname]

          # textual output
          puts "# #{varname} ###########################################"
          puts varvalue.respond_to?(:to_adl) ? varvalue.to_adl : varvalue
          puts

          # image output
          if varvalue.respond_to?(:to_dot)
            output_images(varname, varvalue, dir)
          end
        end
      end

      def output_images(varname, varvalue, dir)
        images.each do |format|
          output_file = File.join(dir, "#{varname}.#{format}")
          puts cmd = "dot -q -T#{format} -o#{output_file}"
          IO::popen(cmd, "w") do |io|
            io << varvalue.to_dot
          end
        end
      end

    end # class Run
  end # class Command
end # module Stamina