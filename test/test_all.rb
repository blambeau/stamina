$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'test')
test_files = Dir['**/*_test.rb']
test_files.each { |file|
  require(file) 
}                                                                                                                                    