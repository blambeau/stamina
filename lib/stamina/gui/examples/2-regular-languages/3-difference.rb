ab_star = regular("(a b)*")

# The difference of a regular language with itself is empty
empty = (ab_star - ab_star) 
assert empty.empty?

