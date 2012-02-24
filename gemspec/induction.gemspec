Kernel.load File.expand_path('../commons.rb', __FILE__)

Gem::Specification.new do |s|
  populate_gemspec(s, ($lib/"stamina-induction").glob("**/*"))

  s.name          = "stamina-induction"
  s.summary       = "Induction algorithms for the Stamina toolkit"
  s.description   = "Stamina-induction plugs induction algorithm to the stamina toolkit."
  s.require_paths = ["lib/stamina-induction"]

  s.add_dependency("stamina-core", "= #{$version}")
  s.add_dependency("citrus", "~> 2.4")
end
