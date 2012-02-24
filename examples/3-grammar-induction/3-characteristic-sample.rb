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

characteristic = sample <<-ADL
  # Sp(L) - short prefixes
  # ?
  # ? a
  # ? a b
  #
  # N(L) - kernel
  # ?
  # ? a
  # ? a a
  # ? a b
  # ? a b b
  # ? a b a
  #
  # these strings for the first condition of the characteristic
  # sample specification
  +
  + a b
  + a a b
  + a b b
  + a b a
  # these strings for the second condition
  - a
  - b
  - a a
  + a b b a
  - a b a b
  - a a a
  - b b
  - b b b
  + a b b b
  - b a
  - b a b
ADL

learned = rpni(characteristic)
assert learned <=> target