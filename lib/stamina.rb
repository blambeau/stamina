require 'set'
require 'enumerator'
require 'stringio'

begin
  require_relative 'stamina-core/stamina-core'
  require_relative 'stamina-induction/stamina-induction'
  require_relative 'stamina-gui/stamina-gui'
rescue LoadError
  require 'stamina-core'
  require 'stamina-induction'
  require 'stamina-gui'
end