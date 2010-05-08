require 'grit'

module GitHooks
  class GitAdapter
    include Grit
    
    class Commits
      include Enumerable
      
      attr_reader :ref_name, :repo_name
      
      def initialize(commits, ref_name, repo)
        @commits       = commits
        self.ref_name  = ref_name
        self.repo_name = repo
      end
      
      def each
        @commits.each { |commit| yield commit }
      end
      
      def size
        @commits.size
      end
      
      private
      
        def ref_name=(ref_name)
          @ref_name ||= ref_name.split("/").last
        end
        
        def repo_name=(repo)
          return @repo if @repo
          
          splitted_path = repo.path.split("/")
          @repo_name = if (splitted_path.last =~ /\.git/) > 0
            splitted_path.last.split(".").first
          else
            splitted_path[-2]
          end
        end
      
    end
    
    attr_reader :repo

    def initialize
      @repo = Repo.new(GitAdapter.find_git_root)
    end

    def find_commits_since_last_receive(prev_rev, current_rev, ref_name = 'master')
      commits = repo.commits_between(prev_rev, current_rev)

      return Commits.new(commits, ref_name, @repo)
    end

    def self.find_git_root
      current_dir = Dir.pwd.split('/')
      while current_dir.last !~ /\.git/
        current_dir.pop
        break if current_dir.empty?
      end

      return current_dir.join('/')
    end

  end
end