require 'curb'

module GitHooks
  module Notifier
    class TrackerClient
      
      attr_reader :curl

      def self.deliver(options)
        commits = options.delete(:commits)

        client_instance = new(options)
        client_instance.deliver(commits)
      end
      
      def initialize(tracker_options)
        @curl = Curl::Easy.new("http://www.pivotaltracker.com/services/v3/source_commits") do |curl| 
          curl.headers["X-TrackerToken"] = tracker_options[:api_key]
          curl.headers["Content-type"] = "application/xml"
        end
      end

      def deliver(commits)
        create_payloads(commits) do |payload|
          curl.http_post(payload)
        end
      end
      
      def create_payloads(commits, &block)
        payloads = commits.map do |commit|
          <<-XML
<source_commit>
<message>#{commit.message}</message>
<author>#{commit.author.name}</author>
<commit_id>#{commit.id}</commit_id>
</source_commit>
          XML
        end
        
        payloads.each(&block)
      end
      
    end
  end
end