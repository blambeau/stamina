module Stamina
  module Gui
    class Examples
      include Enumerable

      # Category where examples are located
      FOLDER = Stamina::EXAMPLES_FOLDER

      def each
        Dir[File.join(FOLDER, "*")].sort.each do |file|
          next unless File.directory?(file)
          yield(Category.new(file))
        end
      end

      class Category
        include Enumerable

        attr_reader :folder

        def initialize(folder)
          @folder = folder
        end

        def url
          File.basename(folder)
        end

        def label
          File.basename(folder) =~ /^\d+-(.*)$/
          $1.gsub(/-/, " ").capitalize
        end

        def each
          Dir[File.join(folder, "*.rb")].sort.each do |file|
            yield(Example.new(file))
          end
        end

      end # class Category

      class Example

        attr_reader :file

        def initialize(file)
          @file = file
        end

        def url
          File.basename(file, ".rb")
        end

        def label
          File.basename(file) =~ /^\d+-(.*)\.rb$/
          $1.gsub(/-/, " ").capitalize
        end

        def source
          File.read(file)
        end

      end # class Example

    end # class Examples
  end # module Gui
end # module Stamina