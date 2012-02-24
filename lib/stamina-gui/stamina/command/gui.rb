module Stamina
  class Command
    #
    # Launches the Stamina Web GUI
    #
    # SYNOPSIS
    #   #{program_name} #{command_name}
    #
    class Gui < Quickl::Command(__FILE__, __LINE__)

      # Command execution
      def execute(args)
        Stamina::Gui::App.run!
      end

    end # class Gui
  end # class Command
end # module Stamina