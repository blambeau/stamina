lang = automaton <<-ADL
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

# In a canonical automaton A(lang) of language `lang`, the set of short prefixes 
# is the set of first strings in standard order, each leading to a particular 
# state of the canonical automaton. As a consequence, there are as many short 
# pre-fixes as states in A(lang). In other words, the short prefixes uniquely 
# identify the states of A(lang).
prefixes = short_prefixes(lang)

# The kernel of a language is made of its short prefixes extended by one symbol 
# together with the empty string. By construction, the short prefixes all belong
# to the kernel. The kernel elements capture the transitions of the canonical 
# automaton A(lang). Indeed, they are obtained by adding one symbol to the short 
# pre-fixes which capture its states.
kernel   = kernel(lang)
