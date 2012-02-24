Kernel.load File.expand_path('../stamina-gemspec.rb', __FILE__)

Gem::Specification.new do |s|
  populate_gemspec(s, ($root/"bin").glob("**/*") + [ $root/"lib/stamina.rb" ])

  s.name          = "stamina"
  s.summary       = "Automaton and Regular Inference Toolkit"
  s.description   = "Stamina is an automaton and regular inference toolkit initially "\
                    "developped for the \nbaseline of the Stamina Competition "\
                    "(stamina.chefbe.net)."
  s.require_paths = ["lib"]

  s.bindir        = "bin"
  s.executables   = ($root/:bin).glob("**/*").map{|f| f.basename.to_s}

  s.add_dependency("stamina-core",      "= #{$version}")
  s.add_dependency("stamina-induction", "= #{$version}")
  s.add_dependency("stamina-gui",       "= #{$version}")
end
