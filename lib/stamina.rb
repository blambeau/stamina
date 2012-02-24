require 'set'
require 'enumerator'
require 'stringio'

require_relative 'stamina/version'
require_relative 'stamina/loader'
require_relative 'stamina/errors'

module Stamina

  EXAMPLES_FOLDER = File.expand_path("../../examples", __FILE__)

end

require_relative 'stamina/ext/math'
require_relative 'stamina/markable'
require_relative 'stamina/adl'
require_relative 'stamina/sample'
require_relative 'stamina/input_string'
require_relative 'stamina/classifier'
require_relative 'stamina/automaton'
require_relative 'stamina/scoring'
require_relative 'stamina/utils'
require_relative 'stamina/induction/union_find'
require_relative 'stamina/induction/commons'
require_relative "stamina/induction/rpni"
require_relative "stamina/induction/blue_fringe"
require_relative "stamina/reg_lang"
require_relative "stamina/dsl"
require_relative "stamina/engine"

module Stamina
  extend Stamina::Dsl
end