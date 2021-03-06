code = <<-ADL
# First, it allows line comments 'a la' ruby, that is, lines starting with '#'
# are simply ignored. Whitespaces may also be inserted before the comment symbol
# like
      # this
# Empty lines are also ignored:

# Still about comments and whitespaces: end-of-line comments are NOT supported
# because they would not allow using '#' as a input string symbol. Whitespaces
# and tabs are allowed (and ignored) at begining and end of lines as well as
# between input symbols (see later).

# Next, a sample is a sequence of input strings, separated by newlines (aka
# carriage return). An input string is simply a sequence of input symbols,
# separated by whitespace(s) or tabs. Symbols are simple characters or words.
# An input string is labeled as positive if its first symbol is '+', negative
# if it's '-' and unlabeled of the first symbol is '?' ('+', '-' and '?' symbols
# won't be not part of the input string itself). If the string does not start with one
# of these symbols, it is considered as an error string and ADL raises an error.
# '+', '-' and '?' anywhere else in the string count for themselve. So, positive,
# negative and unlabeled strings respectively looks like:
+ a b a b
- a a
? a b

# That's all ... here are some other examples and comments:

# This is the positive empty string (negative empty string is a simple '-' line,
# not shown here because it would create an inconsistent sample; unlabeled empty
# string is simply the '?' line):
+

# We've said earlier that words are accepted as input symbols, and we warn you
# that the following strings are not equivalent (the first has two symbols only,
# the second has ten symbols and the last has only one.
+ hello world
+ h e l l o w o r l d
+ helloworld

# but whitespaces and tabs do not count, so the following positive string is already
# part of this sample:
        + h   e l l   o w   o r l    d

# The following strings are supported: '+' and '-' count for themselve, expect
# the first, and the last is part of a '+a' symbol.
+ a + b - a - b +a

# A last example, to insist on comment rules: here all '#" count for themselve:
+ # a # b a b            # and all these words are symbols too !!

# This sample grammar does not provide a way to define empty symbols
# (something like '', which is interpreted for itself) nor does it provide an
# epsilon predefined character. You'll have to post-process your sample
# yourself, sorry!
ADL
result = sample(code)