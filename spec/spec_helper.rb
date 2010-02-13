require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'git_hooks'

Spec::Runner.configure do |config|
end
