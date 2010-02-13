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
          !@roster[jid]
        end
      end

      def initialize
        jid      = JID.new('codingmonkey@galaxycats.com/Git')
        password = ':X'

        @backend = Client.new(jid)
        @backend.connect("talk.google.com")
        @backend.auth(password)
      end

      def groups
        {
          :galaxy_cats => [
            Buddy.new("dirk@galaxycats.com", roster)
            # "ethem@galaxycats.com",
            # "andi@galaxycats.com",
            # Buddy.new("basti@galaxycats.com", roster)
          ]
        }
      end
      
      def buddies
        roster.items.map { |roster_item| Buddy.new(roster_item.last.jid, roster) }
      end

      def roster
        @roster ||= Roster::Helper.new(@backend)
      end

      def send(options)
        send_message_to create_message(options[:commits]), options[:to]
        true
      end
      
      def request_authorization_of(recipient)
        request = Jabber::Presence.new
        request.to = recipient.respond_to?(:jid) ? recipient.jid : recipient
        request.type = :subscribe
        @backend.send request
      end

      # private

        def create_message(from_commits)
          message = "The following commits have pushed to the repository '#{from_commits.repo_name}' on '#{from_commits.ref_name}':\n"
          from_commits.each do |commit|
            message << "\t#{commit.id[0...5]}...: '#{commit.short_message}' by #{commit.author.name}\n"
          end

          message
        end

        def send_message_to(message, to)
          recipients = [groups[to] || Buddy.new(to, roster)].flatten

          puts "-- recipients: #{recipients.inspect}"
          recipients.each do |recipient|
            puts "-- recipient: #{recipient.inspect}"
            puts "-- is_subscribed?: #{recipient.subscribed?}"
            subject = "Git commit notification"

            request_authorization_of(recipient) unless recipient.subscribed?

            msg = Message::new(recipient, message).set_type(:normal).set_id('1').set_subject(subject)
            @backend.send msg
          end
        end

    end
  end
end