require 'git_hooks/utils/config'

module GitHooks
  module Utils

    class <<self
      def hostname
        `hostname -s`.strip
      end
      
      def config
        Config.instance
      end
    end
    
  end
end
