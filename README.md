# What is Stamina?

This Stamina distribution is an implementation of the well-known regular induction algorithms RPNI (Regular Positive and Negative Inference) and RedBlue (aka BlueFringe). It has been implemented during the Stamina regular language inference challenge in 2010, challenge initiated by Kyril Bogdanov and Neil Walkinshaw (University of Shefield, England) as well as Christophe Damas, Pierre Dupont and Bernard Lambeau (Universite catholique de Louvain, UCL, Belgium)

It's official maintainer is Bernard Lambeau. Any comment, question, bug report, etc. to be adressed to bernard dot lambeau at uclouvain dot be or, better, on the supporting {redmine bugtracker}[http://redmine.chefbe.net/projects/stamina].

## How to install it?

This stamina distribution requires Ruby >= 1.8.6. It has been tested under Linux and MacOS, with ruby 1.8.6, 1.8.7 and 1.9.1. Please make sure that you use one of these versions on your computer. Stamina has no gem dependency (gems are reusable ruby libraries, available through rubyforge.com repository).

If you are new to Ruby and need to install it, you can use this typical command (we assume you have an ubuntu/linux, you can also download ruby from http://www.ruby-lang.org/en/downloads):

    apt-get install ruby rake irb rdoc rubygems

Then, you should have the following commands available in your PATH: _ruby_, _irb_, _rdoc_ and _gem_. Now, try the following commands:

    rake rdoc   # generates the HTML API documentation in doc/api
    rake test   # runs all the tests (please report any failure on redmine)

== Available binaries

The following stamina binaries are in the bin folder (all accept a --help option)

[adl2dot] Converts a .adl file (the description of an automaton) to a dot or gif file.
          Generating a .gif file requires <code>dot</code> in your path.
[rpni] Regular Positive and Negative Inference as a commandline tool. Induces a DFA from
       a sample file.
[redblue] The blue-fringe heuristic applied to RPNI. Induces a DFA from a sample file.
[classify] Classifies a test sample against an automaton and generates a binary signature
           (typically needed to submit results on the competition website).

## Competition use case

Assume that you've downloaded the 31'th problem proposed on the competition website (alphabet of size 5, learning sample sparsity of 25%) and that you put the learning and test data files in example/competition/31_learning.adl and example/competition/31_test.adl (they are already included in this distribution).

Now, you can run RPNI on the training set using the following command

  ./bin/rpni --verbose --output example/competition/31_rpni_result.adl example/competition/31_learning.adl

And you can classify the test set using the induced automaton (generate the binary signature that will be uploaded on the competition server) using the following one:

  ./bin/classify example/competition/31_test.adl example/competition/31_rpni_result.adl

This will generate a string containing 0 and 1, which is the binary signature expected by the server.

Now, you have to create your own induction algorithm. For this, "monkey-see-monkey-do" is a good way to start. Have a look (and copy the following files) at (see also the Roadmap section below)

[bin/rpni] the command line tool (almost empty)
[lib/stamina/command/rpni_command.rb] the implementation of the command itself (parsing arguments and files)
[lib/stamina/induction/rpni.rb] the implementation of RPNI itself

A bit of automation and you're ready to become one of the best competition challengers ;-)

== Main features

1. An Automaton class, providing a rich API as well as walking and binary classification methods
2. Parsing utilities for automata and samples
3. Dot utilities to visualize automata using dot
4. RPNI and RedBlue implementations, based on a useful UnionFind data structure
5. A reusable architecture for creating state-merging induction algorithms.

== Roadmap inside the code

Following ruby project conventions, source code is under lib/stamina, test code under test/stamina, binaries under bin.

Main classes of this project are:
1. Stamina::Automaton, which provides a rich automaton implementation. Also have a look
   at the Stamina::Automaton::Walking module, which automatically provides a rich set of
   walking methods to the Automaton class (that is, instances methods or the module are
   available as instance methods of any automaton object)
2. Stamina::InputString and Stamina::Sample, which provides labeled strings (positive or
   negative) as well as a sample implementation (a set of strings).
3. Stamina::ADL, which provides parsing and printing methods for automata and samples.
4. Stamina::Induction::Commons, Stamina::Induction::RPNI and Stamina::Induction::RedBlue
   respectively provide common methods of the two algorithms (sample2pta, pta2unionfind,
   etc.) as well as the algorithm implementations themselve.
5. Stamina::Induction::UnionFind implements a UnionFind data structure dedicated to the
   induction algorithms.