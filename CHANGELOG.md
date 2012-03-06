# O.5.4 / FIX ME

* InputString and Sample have been moved from stamina-induction to stamina-core as ADL
  and Walking rely on them.

# 0.5.3 / 2012-02-25

* Resolve accuracy between github tags and rubygems

# 0.5.2 / 2012-02-25

* Bug fixes

  * Fixed the decoration algorithm on non deterministic automata. Initial states
    considered are only those explicitly marked as initial (:initial => true) and not
    all states reached through epsilon symbols.

# 0.5.1 / 2012-02-24

* Bug fixes

  * Fixed external requires in the different gems (no such file to load sinatra)

# 0.5.0 / 2012-02-24

* Breaking features.

  * Support for ruby 1.8.7 has been definitely removed.

* Major enhancements

  * The project has been split in different sub gems (core, induction and gui). This
    implies a lot of internal changes, but the public API has not been affected. A main
    'stamina' gem automatically includes all sub gems so previous behavior is guaranteed.

* Minor enhancements
    * Fixed a bug with bundler usage in main stamina binary
    * adl2dot command now support samples as input in addition to automata. In that case,
      the dot result models a PTA (prefix tree acceptor)
    * Added --png to 'stamina adl2dot'

# 0.4.0 / 2011-05-01

* Major Enhancements

    * Added Automaton#to_adl as an shortcut for Stamina::ADL::print_automaton(...)
    * Added Sample#to_pta taken from Induction::Commons
    * Added Automaton completion (all strings parsable) under Automaton#complete[!?]
    * Added Automaton stripping (removal of unreachable states) under Automaton#strip[!]
    * Added Automaton minimization (Hopcroft + Pitchies) under Automaton#minimize
    * Added Abbadingo generators under Abbadingo::RandomDFA and Abbadingo::RandomSample
    * Added a main 'stamina' command relying on Quickl. classiy/adl2dot commands become
      subcommands of stamina itself (see stamina --help for a list of available commands).
      Induction command (rpni and redblue) are now handled by a 'stamina infer' with
      options.
    * Error states and now correctly handled in ADL::parse and ADL::flush
    * RedBlue has been renamed as BlueFringe everywhere (red_?blue -> blue_fringe)

* Minnor Enhancements
    * Added a few optimizations here and there

* Bug fixes

    * Fixed a bug in Automaton#depth when some states are unreachable

# 0.3.1 / 2011-03-24

* Major Enhancements

    * Implemented the decoration algorithm of Damas10, allowing to decorate states
      with information propagated from states to states until a fixpoint is reached.
    * Added Automaton::Metrics module, automatically included, with useful metrics
      like automaton depth, accepting ratio and so on.
    * Added Scoring module and Classifier#classification_scoring(sample) method
      with common measures from information retrieval.

* On the devel side

    * Moved specific automaton tests under test/stamina/automaton/...

# 0.3.0 / 2011-03-24

* On the devel side

  * The project structure is now handled by Noe
  * Ensures that tests are correctly executed under ruby 1.9.2


# 0.2.2 / 2010-10-22

* Major Enhancements

  * Sample#<< does not detect inconsistencies anymore, to ensure a linear method instead of a quadratic one.

* On the devel side

  * Fixes a bug in Rakefile that lead to test failures under ruby 1.8.7

# 0.2.1 / 2010-05-01

* Main public version for the official competition, extracted from private SVN.