#!/usr/bin/env ruby
require File.expand_path('../commons', __FILE__)

algorithms  = [:rpni, :bluefringe]
proportions = [1.0, 0.5, 0.25, 0.125, 0.06, 0.03]
samples     = Dir["grid/*.training.adl"].sort{|x,y|
  File.basename(x) =~ /^(\d+)\-(\d+)/
  sx, nx = $1.to_i, $2.to_i
  File.basename(y) =~ /^(\d+)\-(\d+)/
  sy, ny = $1.to_i, $2.to_i
  (sx <=> sy) != 0 ? sx <=> sy : nx <=> ny
}

samples.each do |trainingset|
  basename = File.basename(trainingset, ".training.adl")
  testset  = "grid/#{basename}.test.adl"
  proportions.reverse.each do |prop|
    algorithms.each do |algo|
      options = ['--algorithm', algo.to_s, '--drop', '--take', prop.to_s, '--score', testset, trainingset]
      puts "stamina infer #{options.join(' ')}"
    end
  end
end

