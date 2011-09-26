require 'stamina'
require 'stamina/abbadingo'
Viiite.bench do |b|
  b.variation_point :version, Stamina::VERSION
  b.variation_point :ruby, Viiite.which_ruby
  b.range_over([16, 32, 64, 128, 256, 512], :req_size) do |size|
    bench_case = Stamina::Abbadingo::RandomDFA.execute(size, 0.5, :minimize => nil)
    b.with(:state_count => bench_case.state_count) do
      b.report(:hopcroft){ Stamina::Automaton::Minimize::Hopcroft.execute(bench_case) }
      b.report(:pitchies){ Stamina::Automaton::Minimize::Pitchies.execute(bench_case) }
    end
  end
end
