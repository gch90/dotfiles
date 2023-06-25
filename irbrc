begin
  require 'rubygems'
	require "awesome_print"
	AwesomePrint.irb!
  require 'pry'
rescue LoadError
end

if defined?(Pry)
  Pry.start
  exit
end
