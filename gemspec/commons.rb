require 'epath'

$root = Path.dir/".."
$lib  = $root/:lib

require $lib/"stamina-core/stamina/version"
$version = Stamina::Version.to_s

def populate_gemspec(s, files)
  s.version   = $version
  s.homepage  = "https://github.com/blambeau/stamina"
  s.authors   = ["Bernard Lambeau"]
  s.email     = ["blambeau@gmail.com"]

  files       = [ $root/"LICENCE.md", $root/"CHANGELOG.md" ] + files
  s.files     = files.map{|f| f.relative_to(Path.pwd).to_s}
end