module GitHooks
  class PostReceiveHook
    
    def initialize
      @git_adapter = GitAdapter.new
    end
    
    def run(*args)
      arguments = read_arguments_from_stdin
      commits   = @git_adapter.find_commits_since_last_receive(*arguments)
      
      post_receive_hooks = GitHooks::Utils::Config.post_receive_hooks
      
      post_receive_hooks.each do |hook|
        hook.hook_class.deliver(hook.options.merge(:commits => commits))
      end
    end
    
    def read_arguments_from_stdin
      arguments = []
      
      while arguments << STDIN.gets
        break if arguments.last.nil?
      end
      
      arguments.compact.first.split(" ")
    end
  end
  
end