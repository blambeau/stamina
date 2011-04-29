require File.expand_path('../../commons', __FILE__)
sample = Stamina::ADL::parse_sample_file File.expand_path('../128-test.adl', __FILE__)
sample.to_pta
