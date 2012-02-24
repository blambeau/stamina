task :gem do
  require 'epath'

  (Path.dir/"../gemspec").glob("*.gemspec").each do |file|
    `mkdir -p pkg`
    puts "Building gemspec/#{file.basename}"
    puts `gem build gemspec/#{file.basename}`
    `mv *.gem pkg`
  end
end
