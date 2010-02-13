require 'grit'
require 'active_support/core_ext/string'

module GitHooks
  class GitAdapter
    include Grit
    
    attr_reader :repo

    def initialize
      @repo = Repo.new(GitAdapter.find_git_root)
    end

    def find_commits_since_last_receive(prev_rev, current_rev, ref_name = 'master')
      commits = repo.commits_between(prev_rev, current_rev)

      commits.instance_eval <<-METH_RUBY
      def ref_name
        "#{ref_name.split("/").last}"
      end

      def repo_name
        splitted_path = "#{repo.path}".split("/")
        repo_name = if (splitted_path.last =~ /\.git/) > 0
          splitted_path.last.split(".").first
        else
          splitted_path[-2]
        end
      end
      METH_RUBY

      return commits
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