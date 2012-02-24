#
# This is the introduction example for Stamina induction algorithms
#
# Classical induction is aimed at learning a regular language from a
# `positive` sample, under the control of a `negative` sample.
#
# Samples are commonly captured through a Prefix Tree Acceptor (PTA).
# A PTA capturing both a positive and a negative sample is called an
# Augmented PTA (APTA)
#

# a positive sample will be captured through a PTA
# (accepting states capture positive strings)
positive = sample <<-SAMPLE
  +
  + a
  + b b
  + b b a
  + b a a b
  + b a a a b a
SAMPLE

# a negative sample will be captured through a PTA
# (no accepting states, but error states capturing negative
# strings)
negative = sample <<-SAMPLE
  - b
  - a b
  - a b a
SAMPLE

# The union of samples is recognized as follows, and captured through
# an APTA (observe that both accepting and error states are present)
training = positive + negative