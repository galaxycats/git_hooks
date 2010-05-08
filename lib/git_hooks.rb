$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require 'active_support/core_ext/string'

require 'git_hooks/notifier'
require 'git_hooks/git_adapter'
require 'git_hooks/post_receive_hook'
require 'git_hooks/logger'
require 'git_hooks/utils'

module GitHooks
  
  class <<self
    attr_writer :config_file
    
    def config
      @config_instance ||= Utils::Config.new(config_file)
    end
    
    def config_file
      @config_file || "~/.git_hooks_config"
    end

    def run_hook(name_of_hook, *args)
      hook = "GitHooks::#{name_of_hook.to_s.camelize}Hook".constantize.new
      hook.run(*args)
    end
  end
  
end