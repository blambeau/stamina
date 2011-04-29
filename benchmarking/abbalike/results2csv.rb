headers = nil
File.readlines(File.expand_path('../results.rb', __FILE__)).each do |line|
  h = Kernel.eval(line.gsub /Infinity/, '1.0/0.0')
  dfasize, index = h[:sample].match(/^(\d+)\-(\d+)/)[1..2]
  h[:dfa_size], h[:index] = dfasize.to_i, index.to_i
  if headers.nil?
    headers = h.keys 
    puts headers.join(';')
  end
  puts headers.collect{|k| h[k]}.collect{|x|
    case x
      when Float
        "%.8f" % x
      when Integer
        "%d" % x
      else 
        x.to_s
    end
  }.join(';')
end

