task :gem do
  require 'epath'

  `rm -rf pkg && mkdir pkg`
  (Path.dir/"..").glob("*.gemspec").each do |file|
    puts "Building #{file.basename}"
    puts `gem build #{file.basename}`
    `mv *.gem pkg`
  end
end
