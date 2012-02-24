Kernel.load File.expand_path('../commons.rb', __FILE__)

Gem::Specification.new do |s|
  populate_gemspec(s, ($root/"bin").glob("**/*"))

  s.name          = "stamina"
  s.summary       = "Automaton and Regular Inference Toolkit"
  s.description   = "Stamina is an automaton and regular inference toolkit initially "\
                    "developped for the \nbaseline of the Stamina Competition "\
                    "(stamina.chefbe.net)."
  s.require_paths = ["lib"]

  s.add_dependency("stamina-core",      "= #{$version}")
  s.add_dependency("stamina-induction", "= #{$version}")
  s.add_dependency("stamina-gui",       "= #{$version}")
end
