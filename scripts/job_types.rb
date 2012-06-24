#!/usr/bin/env ruby
while line = gets()
  break if line.to_i == 0
  print "->  #{line.to_s.reverse.to_i(2)}\n"
end
