require File.expand_path('../../commons', __FILE__)

size = 128

# Generate a dfa and a training sample
dfa_file = File.expand_path("../#{size}.adl", __FILE__)
sample_file = File.expand_path("../#{size}-training.adl", __FILE__)
Stamina::Command.run ["abbadingo-dfa", "--size", "#{size}", "--output", dfa_file]
Stamina::Command.run ["abbadingo-samples", dfa_file]

# Lets do it
sample = Stamina::ADL::parse_sample_file(sample_file)
p, h = 1.0, {}
begin
  h[p] = Benchmark.measure{ sample.to_pta }
  sample, p = sample.take(0.5), p/2
end while sample.size > 100

# Output the graph
x = h.keys.sort
y = h.keys.sort.collect{|p| h[p].total}
Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.terminal "gif"
    plot.output   File.expand_path("../to_pta.#{size}.gif", __FILE__)
  
    # see sin_wave.rb
    plot.xrange "[0:1.0]"
    plot.title  "Sample"
    plot.ylabel "time (sec)"
    
    plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
      ds.with = "linespoints"
      ds.linewidth = 1
      ds.title = "to_pta"
    end
    
  end
end

