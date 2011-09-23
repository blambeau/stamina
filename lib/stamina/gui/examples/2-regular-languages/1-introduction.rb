#
# Stamina recognizes regular expressions thanks the `regular` function.
#

# Let's build a regular language
abstar = regular("(a b)*")

# More complex regular languages may be put on multiple lines
complex = regular <<-LANG
  (a b)+
| a+
| b
LANG

# Sometimes, it is useful to capture the universal regular language 
# over an alphabet, that is,
univ = regular("(a | b | c | d | e)*")

# Here is a friendly shortcut, very useful if the alphabet become 
# large
univ2 = sigma_star('a'..'e')
assert univ <=> univ2

