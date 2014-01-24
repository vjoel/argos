require 'argos'

v = 0
defaults = {
  "v"     => v,
  "port"  => 4000,
  "host"  => "localhost"
}

optdef = {
  "x"     => true,
  "y"     => "y",
  "z"     => 3,
  "v"     => proc {v+=1}, # no argument, but call the proc to get the value
  "port"  => proc {|arg| Integer(arg)},
  "n"     => proc {|arg| Integer(arg)},
  "t"     => proc {|arg| Float(arg)},
  "cmd"   => proc {|arg| arg.split(",")}
}

ARGV.replace %w{
  -xyzn5 somefile --port 5000 -t -1.23 -vv -v --unrecognized-option
  --cmd=ls,-l otherfile -- --port
}

begin
  cli_opts = Argos.parse_options(ARGV, optdef)
rescue Argos::OptionError => ex
  $stderr.puts ex.message
  exit
end

opts = defaults.merge cli_opts

p opts
p ARGV
unless ARGV.empty?
  puts "Some arg-looking strings were not handled:", *ARGV.grep(/^-./)
end
