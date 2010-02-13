require 'grit'
require 'active_support/core_ext/string'

module GitHooks
  
  def self.run_hook(name_of_hook, *args)
    hook = "GitHooks::#{name_of_hook.to_s.camelize}Hook".constantize.new
    hook.run(*args)
  end
  
  class GitAdapter
    include Grit
    
    def initialize
      @repo = Repo.new(find_git_root)
    end
    
    def find_commits_since_last_receive(prev_rev, current_rev, ref_name = 'master')
      @repo.commits_between(prev_rev, current_rev)
    end
    
    private
    
      def find_git_root
        current_dir = Dir.pwd.split('/')
        while current_dir.last !~ /\.git/
         current_dir.pop
         break if current_dir.empty?
        end

        return current_dir.join('/')
      end
    
  end
  
  class Notifier
    require 'xmpp4r'
    
    include Jabber
    
    def jabber(options)
      send_message_to create_message(options[:commits]), options[:to]
    end
    
    private
    
      def create_message(from_commits)
        message = "The following commits have pushed to the repository 'REPO_NAME':\n"
        from_commits.each do |commit|
          message << "\t#{commit.id[0...5]}...: '#{commit.short_message}' by #{commit.author.name}\n"
        end
        
        message
      end
      
      def jabber_client
        return @cl if @cl

        jid = JID::new('samwise@jabber.org')
        password = 'PASSWORD'
        @cl = Client::new(jid)
        @cl.connect
        @cl.auth(password)

        @cl
      end

      def send_message_to(message, to)
        subject = "XMPP4R test"
        m = Message::new(to, message).set_type(:normal).set_id('1').set_subject(subject)
        jabber_client.send m
      end
      
      # def repo_name
      #   splitted_path = Dir.pwd.path.split("/")
      #   @repo_name = if splitted_path =~ /\.git/ > 0
      #     splitted_path.last.split(".").first
      #   else
      #     splitted_path[-1]
      #   end
      # end
    
  end
  
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
      puts "params: #{params.inspect}"

      commits = @git_adapter.find_commits_since_last_receive(*params.first.split(" "))

      @notifier.jabber(:commits => commits, :to => "dirk@galaxycats.com")
    end
    
  end
  
end