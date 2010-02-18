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

      def initialize
        init_jabber_backend!
      end

      def groups(to_send_to)
        if group = GitHooks::Utils.config.notifier["jabber"]["recipients"][to_send_to]
          group.map do |recipient|
            Buddy.new(recipient, roster)
          end
        else
          nil
        end
      end
      
      def buddies
        roster.items.map { |roster_item| Buddy.new(roster_item.last.jid, roster) }
      end

      def roster
        @roster ||= Roster::Helper.new(backend)
      end

      def send(options)
        send_message_to create_message(options[:commits]), options[:to]
        true
      end
      
      private unless $TESTING
      
        def init_jabber_backend!
          @backend = Client.new(JID.new(GitHooks::Utils.config.notifier["jabber"]["jid"]))
          @backend.connect(GitHooks::Utils.config.notifier["jabber"]["server"])
          @backend.auth(GitHooks::Utils.config.notifier["jabber"]["password"])
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

        def send_message_to(message, to)
          recipients = [groups(to) || Buddy.new(to, roster)].flatten

          recipients.each do |recipient|
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