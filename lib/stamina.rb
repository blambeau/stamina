module Stamina
  
  # The current version of Stamina.
  VERSION = "0.2.1".freeze

end

require 'set'
require 'enumerator'
require 'stamina/errors'
require 'stamina/markable'
require 'stamina/adl'
require 'stamina/sample'
require 'stamina/input_string'
require 'stamina/classifier'
require 'stamina/automaton'
require 'stamina/automaton_walking'
require 'stamina/induction/union_find'
require 'stamina/induction/commons'
require "stamina/induction/rpni"
require "stamina/induction/redblue"
