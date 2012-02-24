abstar = regular("(a b)*")

# The complement of a regular language language L is defined as
# the set of strings not belonging to L
complement = abstar**-1

# The complement of the complement is the regular language itself
compcomp = complement**-1
assert abstar <=> compcomp

# Also observe that the complement of a regular language can be
# computed explicitly as the
otherway = regular("(a | b)*") - abstar
assert otherway <=> complement