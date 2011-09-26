require 'stamina'
require 'stamina/abbadingo'
Viiite.bench do |b|
  b.variation_point :version, Stamina::VERSION
  b.variation_point :ruby, Viiite.which_ruby
  b.range_over([16, 32, 64, 128, 256, 512], :req_size) do |size|
    cdfa = Stamina::Abbadingo::RandomDFA.execute(size, 0.5)
    bench_case = Stamina::RegLang::CanonicalInfo.new(cdfa)
    b.with(:state_count => cdfa.state_count) do
      b.report(:distinguish){ bench_case.send(:build_distinguish_matrix) }
    end
  end
end
