$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require 'git_hooks/notifier'
require 'git_hooks/git_adapter'
require 'git_hooks/post_receive_hook'
require 'git_hooks/logger'
require 'git_hooks/utils'

module GitHooks
  
  def self.run_hook(name_of_hook, *args)
    hook = "GitHooks::#{name_of_hook.to_s.camelize}Hook".constantize.new
    hook.run(*args)
  end
  
end