require File.expand_path('../lib/stamina-core/stamina/version', __FILE__)
Gem::Specification.new do |s|
  s.name          = "stamina-gui"
  s.summary       = "A sinatra-driven user interface for the Stamina toolkit"
  s.description   = "Stamina-gui provides a web-based graphical interface for Stamina."
  s.version       = Stamina::VERSION

  s.require_paths = ["lib/stamina-gui"]
  s.files         = [ "LICENCE.md", "CHANGELOG.md" ] +
                    Dir["lib/stamina-gui/**/*"] +
                    Dir['examples/**/*']

  s.homepage  = "https://github.com/blambeau/stamina"
  s.authors   = ["Bernard Lambeau"]
  s.email     = ["blambeau@gmail.com"]

  s.add_dependency("stamina-core",      "= #{$version}")
  s.add_dependency("stamina-induction", "= #{$version}")
  s.add_dependency("sinatra", "~> 1.3")
  s.add_dependency("json",    "~> 1.6")
end
