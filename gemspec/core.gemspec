Kernel.load File.expand_path('../commons.rb', __FILE__)

Gem::Specification.new do |s|
  populate_gemspec(s, ($lib/"stamina-core").glob("**/*"))

  s.name          = "stamina-core"
  s.summary       = "Automaton and Regular Inference Toolkit"
  s.description   = "Stamina is an automaton and regular inference toolkit initially "\
                    "developped for the \nbaseline of the Stamina Competition "\
                    "(stamina.chefbe.net)."
  s.require_paths = ["lib/stamina-core"]

  s.add_dependency("quickl", "~> 0.4.3")
end
