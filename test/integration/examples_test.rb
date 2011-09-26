require 'test/unit'
require 'stamina'
require 'stamina/gui/examples'
module Stamina
  class ExamplesTest < Test::Unit::TestCase

    def test_examples
      pattern = File.join(Stamina::Gui::Examples::FOLDER, "**", "*.rb")
      Dir[pattern].each do |file|
        begin
          Stamina::Engine.execute File.read(file)
        rescue => ex
          puts ex.message
          puts ex.backtrace.join("\n")
          assert false, "File #{file} does not raise error"
        end
      end
    end

  end
end
