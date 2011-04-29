#!/usr/bin/env ruby
require File.expand_path('../commons', __FILE__)

sizes   = [32, 64, 128]
howmuch = 5

sizes.each do |size|
  howmuch.times do |i|
    puts "stamina abbadingo-dfa --size #{size} --output grid/#{size}-#{i}.adl"
    puts "stamina abbadingo-samples grid/#{size}-#{i}.adl"
  end
end
