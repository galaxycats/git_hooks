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
      commits = @repo.commits_between(prev_rev, current_rev)
      
      commits.instance_eval <<-METH_RUBY
      def ref_name
        "#{ref_name.split("/").last}"
      end
      
      def repo_name
        splitted_path = "#{@repo.path}".split("/")
        repo_name = if (splitted_path.last =~ /\.git/) > 0
          splitted_path.last.split(".").first
        else
          splitted_path[-2]
        end
      end
      METH_RUBY
      
      return commits
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
    require 'xmpp4r/roster'
    
    include Jabber
    
    def jabber(options)
      send_message_to create_message(options[:commits]), options[:to]
    end
    
    private
    
      def groups
        {
          :galaxy_cats => [
            "dirk@galaxycats.com",
            "ethem@galaxycats.com",
            "andi@galaxycats.com",
            "basti@galaxycats.com"
          ]
        }
      end
    
      def create_message(from_commits)
        message = "The following commits have pushed to the repository '#{from_commits.repo_name}' on '#{from_commits.ref_name}':\n"
        from_commits.each do |commit|
          message << "\t#{commit.id[0...5]}...: '#{commit.short_message}' by #{commit.author.name}\n"
        end
        
        message
      end
      
      def jabber_client
        return @cl if @cl

        jid = JID.new('codingmonkey@galaxycats.com/Git')
        password = ';-)'
        @cl = Client.new(jid)
        @cl.connect("talk.google.com")
        @cl.auth(password)

        @cl
      end

      def send_message_to(message, to)
        recipients = [groups[to] || to].flatten
        
        recipients.each do |recipient|
          subject = "Git commit notification"
          
          if recipient_needs_authorization?(recipient)
            request_authorization_of_recipient(recipient)
          else
            msg = Message::new(to, message).set_type(:normal).set_id('1').set_subject(subject)
            jabber_client.send msg
          end
        end
        
      end
      
      def recipient_needs_authorization?(recipient)
        roster = Roster::Helper.new(jabber_client)
        recipient_jid = JID.new(recipient)
        !!roster.items[recipient_jid]
      end
      
      def request_authorization_of_recipient(recipient)
        request = Jabber::Presence.new
        request.to = recipient
        request.type = :subscribe
        jabber_client.send request
      end
    
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

      @notifier.jabber(:commits => commits, :to => :galaxy_cats)
    end
    
  end
  
end