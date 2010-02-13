require 'git_hooks/notifier/jabber_client'

module GitHooks
  module Notifier
    
    class <<self
      def jabber(options)
        jabber_client = JabberClient.new
        jabber_client.send(options)
      end
    end
    
  end
end