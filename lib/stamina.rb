require 'set'
require 'enumerator'
require 'stringio'

require 'stamina/version'
require 'stamina/loader'
module Stamina

  EXAMPLES_FOLDER = File.expand_path("../../examples", __FILE__)

end
require 'stamina/errors'
require 'stamina/ext/math'
require 'stamina/markable'
require 'stamina/adl'
require 'stamina/sample'
require 'stamina/input_string'
require 'stamina/classifier'
require 'stamina/automaton'
require 'stamina/scoring'
require 'stamina/utils'
require 'stamina/induction/union_find'
require 'stamina/induction/commons'
require "stamina/induction/rpni"
require "stamina/induction/blue_fringe"
require "stamina/reg_lang"
require "stamina/dsl"
require "stamina/engine"
module Stamina
  extend Stamina::Dsl
end