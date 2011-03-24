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

