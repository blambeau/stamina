#
# The kernel of a language defines the transitions of it's canonical automaton.
# 
target = automaton <<-ADL
  3 5
  0 true true
  1 false false
  2 false true
  0 1 a
  1 1 a
  1 2 b
  2 2 b
  2 0 a
ADL
kernel  = kernel(target)
