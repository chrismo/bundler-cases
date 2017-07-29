require 'bundler'

Bundler.setup(:default, :group)

$stderr.puts "before", $:
# Bundler.require(:group) # this is broken in 1.13, but can be worked around with this line:
Bundler.require(:group, :default)
$stderr.puts "after", $:

require 'rake'
