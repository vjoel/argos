module Argos
  VERSION = "1.0"

  module_function

  # Raised (a) when an option that takes an argument occurs at the end of the
  # argv list, with no argument following it, or (b) when a handler barfs.
  class OptionError < ArgumentError; end
  
  # Called when an option that takes an argument occurs at the end of the
  # argv list, with no argument following it.
  def argument_missing opt
    raise OptionError, "#{opt}: no argument provided."
  end
  
  def handle opt, handler, *args # :nodoc
    args.empty? ?  handler[] : handler[args[0]]
  rescue => ex
    raise OptionError, "#{opt}: #{ex}"
  end

  # Returns the hash of parsed options and argument values. The +argv+ array
  # is modified: every recognized option and argument is deleted.
  #
  # The +optdef+ hash defines the options and their arguments.
  #
  # Each key is an option name (without "-" chars).
  #
  # The value for a key in +optdef+
  # is used to generate the value for the same key in the options hash
  # returned by this method.
  #
  # If the value has an #arity method and arity > 0, the value is considered to
  # be a handler; it is called with the argument string to return the value
  # associated with the option in the hash returned by the method.
  #
  # If the arity <= 0, the value is considered to be a handler for an option
  # without arguments; it is called with no arguments to return the value of
  # the option.
  #
  # If there is no arity method, the object itself is used as the value of
  # the option.
  #
  # Only one kind of input will cause an exception (not counting exceptions
  # raised by handler code or by bugs):
  #
  # - An option is found at the end of the list, and it requires an argument.
  #   This results in a call to #argument_missing, which by default raises
  #   OptionError.
  #
  def parse_options argv, optdef
    orig = argv.dup; argv.clear
    opts = {}

    loop do
      case (argstr=orig.shift)
      when nil, "--"
        argv.concat orig
        break

      when /^(--)([^=]+)=(.*)/, /^(-)([^-])(.+)/
        short = ($1 == "-"); opt = $2; arg = $3
        unless optdef.key?(opt)
          argv << argstr
          next
        end
        handler = optdef[opt]
        arity = (handler.arity rescue nil)
        opts[opt] =
          case arity
          when nil;   orig.unshift("-#{arg}") if short; handler
          when 0,-1;  orig.unshift("-#{arg}") if short; handle(opt, handler)
          else        handle(opt, handler, arg)
          end

      when /^--(.+)/, /^-(.)$/
        opt = $1
        unless optdef.key?(opt)
          argv << argstr
          next
        end
        handler = optdef[opt]
        arity = (handler.arity rescue nil)
        opts[opt] =
          case arity
          when nil;   handler
          when 0,-1;  handle(opt, handler)
          else        handle(opt, handler, orig.shift || argument_missing(opt))
          end

      else
        argv << argstr
      end
    end

    opts
  end
end
