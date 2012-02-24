code = <<-ADL
# First, it allows line comments 'a la' ruby, that is, lines starting with '#'
# are simply ignored. White spaces may also be inserted between the comment
# symbol like
      # this
# Empty lines are also ignored:

# Still about comments and white spaces: end-of-line comments are also supported
# (see documentation on right later). Moreover, white spaces and tabs are allowed
# at beginning and end of lines as well as between state and edge elements.

# Next, the first (non comment or empty) line of the file must contain the number
# of states then the number of edges of the automaton: (white spaces between them,
# whitespace before and after are allowed) we refer to these two numbers as
# state_count and edge_count respectively (here: five states and six edges)
5 6

# Then, we expect exactly state_count state definitions. A state definition is
# composed of three informations: 1) a state identifier (any string), 2) 'true'
# or 'false' for initial flag, 3) 'true' or 'false' for accepting flag. These
# informations are simply separated by white spaces:
0 true false                   # here a state with identifier 0
                               # this state is initial and not accepting

identified_state false true    # this kind of identifier is also allowed
                               # this state is not initial but is accepting

# other states below ...
2 false false
3 false true
4 false false

# Then, we expect exactly edge_count edge definitions. An edge definition is
# simple as well: source and target state identifiers followed by a labeling
# input symbol (any word).
0 identified_state hello       # the first edge says hello from source
                               # state 0 to state identified_state

identified_state 2 w           # identified_state 'sends' w to state 2

# and other edges below ...
2 3 o
3 4 r
4 4 l
4 0 d

# This automaton grammar does not provide a way to define empty symbols
# (something like '', which is interpreted for itself) nor does it provide an
# epsilon predefined character. You'll have to post-process your automaton
# yourself, sorry!
ADL
result = automaton(code)