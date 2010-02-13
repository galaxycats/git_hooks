module GitHooks
  class PostReceiveHook
    
    def initialize
      @git_adapter = GitAdapter.new
      @notifier    = Notifier.new
    end
    
    def run(*args)
      params = []

      while params << STDIN.gets
        break if params.last.nil?
      end
      
      params.compact!

      commits = @git_adapter.find_commits_since_last_receive(*params.first.split(" "))

      @notifier.jabber(:commits => commits, :to => :galaxy_cats)
    end
  end
  
end