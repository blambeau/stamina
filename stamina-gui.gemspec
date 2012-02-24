Kernel.load File.expand_path('../stamina-gemspec.rb', __FILE__)

Gem::Specification.new do |s|
  populate_gemspec(s, ($lib/"stamina-gui").glob("**/*") + ($root/'examples').glob("**/*"))

  s.name          = "stamina-gui"
  s.summary       = "A sinatra-driven user interface for the Stamina toolkit"
  s.description   = "Stamina-gui provides a web-based graphical interface for Stamina."
  s.require_paths = ["lib/stamina-gui"]

  s.add_dependency("stamina-core",      "= #{$version}")
  s.add_dependency("stamina-induction", "= #{$version}")
  s.add_dependency("sinatra", "~> 1.3")
  s.add_dependency("json",    "~> 1.6")
end
