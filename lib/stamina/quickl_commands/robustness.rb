module Stamina
  module QuicklCommands
    module Robustness

      # Checks that a given file is readable or raises a Quickl::IOAccessError
      def assert_readable_file(file)
        raise Quickl::IOAccessError, "File #{file} does not exists" unless File.exists?(file)
        raise Quickl::IOAccessError, "File #{file} cannot be read"  unless File.readable?(file)
        file
      end
      
      # Checks that a given file is writable or raises a Quickl::IOAccessError
      def assert_writable_file(file)
        raise Quickl::IOAccessError, "File #{file} cannot be written" \
          unless not(File.exists?(file)) or File.writable?(file)
        file
      end
      
    end # module Robustness
  end # module QuicklCommands
end # module Stamina

