require 'xmpp4r'
require 'xmpp4r/roster'

module GitHooks
  module Notifier
    class JabberClient
      include Jabber
      
      class Buddy
        attr_reader :jid

        def initialize(jid, roster_reference)
          @jid = Jabber::JID.new(jid)
          @roster = roster_reference
        end

        def subscribed?
          roster_item = @roster[jid]
          if roster_item
            return roster_item.subscription == :both ? true : false
          end
        end
      end

      def initialize(jabber_options)
        @jabber_options = jabber_options
        init_jabber_backend!
      end

      def create_recipients(recipients)
        [recipients].flatten.map do |recipient|
          recipient.is_a?(Buddy) ? recipient : Buddy.new(recipient, roster)
        end
      end
      
      def buddies
        roster.items.map { |roster_item| Buddy.new(roster_item.last.jid, roster) }
      end

      def roster
        @roster ||= Roster::Helper.new(backend)
      end
      
      def deliver(options)
        commits    = options.delete(:commits)
        recipients = options.delete(:recipients)

        client_instance = new(options)
        client_instance.deliver(commits, recipients)
      end

      def deliver(commits, recipients)
        send_message_to create_message(commits), recipients
        true
      end
      
      private unless $TESTING
      
        def init_jabber_backend!
          @backend = Client.new(JID.new(@jabber_options[:jid]))
          @backend.connect(@jabber_options[:server])
          @backend.auth(@jabber_options[:password])
        end
      
        def backend
          @backend
        end

        def create_message(from_commits)
          message = "[#{GitHooks::Utils.hostname}] #{from_commits.size} commits have been pushed to '#{from_commits.repo_name}' on '#{from_commits.ref_name}':\n"
          from_commits.each do |commit|
            message << "\t#{commit.id[0...5]}...: '#{commit.short_message}' by #{commit.author.name}\n"
          end

          message
        end
        
        def request_authorization_of(recipient)
          request      = Jabber::Presence.new
          request.to   = recipient.respond_to?(:jid) ? recipient.jid : recipient
          request.type = :subscribe
          backend.send request
        end

        def send_message_to(message, recipients)
          create_recipients(recipients).each do |recipient|
            subject = "Git commit notification"

            request_authorization_of(recipient) unless recipient.subscribed?

            msg = Message::new(recipient.jid, message).set_type(:normal).set_id('1').set_subject(subject)
            GitHooks::Logger.debug "msg: #{msg}"
            backend.send msg
          end
        end

    end
  end
end