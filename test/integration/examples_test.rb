require 'test/unit'
require 'stamina'
require 'stamina/gui/examples'
module Stamina
  class ExamplesTest < Test::Unit::TestCase

    def test_examples
      pattern = File.join(Stamina::Gui::Examples::FOLDER, "**", "*.rb")
      Dir[pattern].each do |file|
        assert_nothing_raised do
          Stamina::Engine.execute File.read(file)
        end
      end
    end

  end
end
