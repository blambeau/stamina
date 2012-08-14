require File.expand_path('../lib/stamina-core/stamina/version', __FILE__)
Gem::Specification.new do |s|
  s.homepage  = "https://github.com/blambeau/stamina"
  s.authors   = ["Bernard Lambeau"]
  s.email     = ["blambeau@gmail.com"]

  s.name          = "stamina-induction"
  s.summary       = "Induction algorithms for the Stamina toolkit"
  s.description   = "Stamina-induction plugs induction algorithm to the stamina toolkit."
  s.version       = Stamina::VERSION

  s.require_paths = ["lib/stamina-induction"]
  s.files         = [ "LICENCE.md", "CHANGELOG.md" ] +
                    Dir["lib/stamina-induction/**/*"]

  s.homepage  = "https://github.com/blambeau/stamina"
  s.authors   = ["Bernard Lambeau"]
  s.email     = ["blambeau@gmail.com"]

  s.add_dependency("stamina-core", "= #{$version}")
  s.add_dependency("citrus", "~> 2.4")
end
