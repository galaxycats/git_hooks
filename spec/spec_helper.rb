require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

$TESTING = true

require 'git_hooks'

# init the config class with testing config
config_yaml = StringIO.new <<-YAML
:post_receive_hooks:
-  :jabber:
    :jid: JABBER_USERNAME
    :password: JABBER_PASSWORD
    :server: JABBER_SERVER
    :recipients:
      :group: [ "recipient@jabber.id" ]
  
-  :pivotal_tracker:
    :api_key: API_KEY
YAML
GitHooks.config_file = config_yaml

Spec::Runner.configure do |config|
end
