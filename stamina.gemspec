require File.expand_path('../lib/stamina-core/stamina/version', __FILE__)
Gem::Specification.new do |s|
  s.homepage  = "https://github.com/blambeau/stamina"
  s.authors   = ["Bernard Lambeau"]
  s.email     = ["blambeau@gmail.com"]

  s.name          = "stamina"
  s.summary       = "Automaton and Regular Inference Toolkit"
  s.description   = "Stamina is an automaton and regular inference toolkit initially "\
                    "developped for the \nbaseline of the Stamina Competition "\
                    "(stamina.chefbe.net)."
  s.version       = Stamina::VERSION

  s.require_paths = ["lib"]
  s.files         = [ "LICENCE.md", "CHANGELOG.md" ] +
                    Dir["bin/**/*"] +
                    [ "lib/stamina.rb" ]

  s.bindir        = "bin"
  s.executables   = Dir["bin/**/*"]

  s.homepage  = "https://github.com/blambeau/stamina"
  s.authors   = ["Bernard Lambeau"]
  s.email     = ["blambeau@gmail.com"]

  s.add_dependency("stamina-core",      "= #{Stamina::VERSION}")
  s.add_dependency("stamina-induction", "= #{Stamina::VERSION}")
  s.add_dependency("stamina-gui",       "= #{Stamina::VERSION}")
end
