require File.expand_path('../lib/stamina-core/stamina/version', __FILE__)
Gem::Specification.new do |s|
  s.name          = "stamina-core"
  s.summary       = "Automaton and Regular Inference Toolkit"
  s.description   = "Stamina is an automaton and regular inference toolkit initially "\
                    "developped for the \nbaseline of the Stamina Competition "\
                    "(stamina.chefbe.net)."
  s.version       = Stamina::VERSION

  s.require_paths = ["lib/stamina-core"]
  s.files         = [ "LICENCE.md", "CHANGELOG.md" ] +
                    Dir["lib/stamina-core/**/*"]

  s.homepage  = "https://github.com/blambeau/stamina"
  s.authors   = ["Bernard Lambeau"]
  s.email     = ["blambeau@gmail.com"]

  s.add_dependency("quickl", "~> 0.4.3")
end
