module GitHooks
  class PostReceiveHook
    
    def initialize
      @git_adapter = GitAdapter.new
    end
    
    def run(*args)
      arguments = read_arguments_from_stdin
      commits   = @git_adapter.find_commits_since_last_receive(*arguments)

      Notifier.jabber(:commits => commits, :to => :galaxy_cats)
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