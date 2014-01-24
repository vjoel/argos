argos
====

A slim command-line parser that does one thing well: turn an array of
strings, such as ARGV, into a hash of recognized options and their
arguments, leaving unrecognized strings in the original array.

Argos was Odysseus' faithful dog, who was good at recognizing ;)

Installation
------------

Install as gem:

    gem install 'argos'

or simply copy argos.rb into your project's lib dir.

Synopsis
--------

     require 'argos'

     optdef = {
       "v"   => true,
       "n"   => proc {|arg| Integer(arg)}
     }

     argv = %w{-v -n10 filename}
     opts = Argos.parse_options(argv, optdef)
     p opts    # ==> {"v"=>true, "n"=>10}
     p argv    # ==> ["filename"]

See also [example dir](example/).

Features
--------

- Operates on ARGV or any given array of strings.

- Output is a hash of {option => value, ...}.

- You can merge this hash on top of a hash of defaults if you want.

- Supports both long ("--foo") and short ("-f") options.

- A long option with an argument is --foo=bar or --foo bar.

- A short option with an argument is -fbar or -f bar.

- The options -x and --x are synonymous.

- Short options with no args can be combined as -xyz in place of -x -y -z.

- If -z takes an argument, then -xyz foo is same as -x -y -z foo.

- The string "--" terminates option parsing, leaving the rest untouched.

- The string "-" is not considered an option.

- ARGV (or other given array) is modified: it has all parsed options
  and arguments removed, so you can use ARGF to treat the rest as input files.

- Unrecognized arguments are left in the argument array. You can catch them
  with grep(/^-./), in case you want to pass them on to another program or
  warn the user.

- Argument validation and conversion are in terms of an option definition
  hash, which specifies which options are allowed, the number of arguments
  for each (0 or 1), and how to generate the value from the argument, if any.

- Repetition of args ("-v -v", or "-vv") can be handled by closures. See
  the example below.

- Everything is ducky. For example, handlers only need an #arity method
  and a #[] method to be recognized as callable. Otherwise they are treated
  as static objects.


Limitations
-----------

- A particular option takes either 0 args or 1 arg. There are no optional
  arguments, in the sense of both "-x" and "-x3" being accepted.

- Options lose their ordering in the output hash (but they are parsed in
  order and you can keep track using state in the handler closures).

- There is no usage/help output.


About
-----

Copyright (C) 2006-2014 Joel VanderWerf, mailto:vjoel@users.sourceforge.net.

License is BSD. See [COPYING](COPYING).
