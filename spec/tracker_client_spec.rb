require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TrackerClient" do
  
  before(:each) do
    @tracker_options = { :api_key => "MY_API_KEY" }
  end
  
  it "should create a pivotal tracker ready payload for each passed commit" do
    commit = mock("CommitMock")
    commit.should_receive(:id).and_return("SHA_ID")
    commit.should_receive(:message).and_return("[#1234] Commit Message")
    commit.should_receive(:author).and_return(mock("AuthorMock", :name => "Seras Victoria"))
    
    expected_payload = <<-XML
<source_commit>
<message>[#1234] Commit Message</message>
<author>Seras Victoria</author>
<commit_id>SHA_ID</commit_id>
</source_commit>
    XML
    
    client = GitHooks::Notifier::TrackerClient.new(@tracker_options)
    client.create_payloads([commit]) do |payload|
      payload.should == expected_payload
    end
  end
  
  it "should send commit messages to pivotal tracker" do
    commits = [mock("CommitMock")]
    payload = "some test payload"
    curl = mock("CurlMock")
    curl.should_receive(:http_post).with(payload)
    
    client = GitHooks::Notifier::TrackerClient.new(@tracker_options)
    client.should_receive(:create_payloads).with(commits).and_yield(payload)
    client.should_receive(:curl).and_return(curl)
    
    client.deliver(commits)
  end
  
  it "should initialize client with a curb client ready to post to pivotal tracker" do
    curb = mock("CurbMock")
    headers = {}
    curb.should_receive(:headers).twice.and_return(headers)
    
    Curl::Easy.should_receive(:new).with("http://www.pivotaltracker.com/services/v3/source_commits").and_yield(curb)
    
    client = GitHooks::Notifier::TrackerClient.new(@tracker_options)
    
    headers["X-TrackerToken"].should == @tracker_options[:api_key]
    headers["Content-type"].should == "application/xml"
  end
  
  it "should provide class level deliver methods" do
    deliver_options = {
      :commits => [mock("CommitMock")],
      :api_key => "MY_API_KEY"
    }
    
    client = mock("TrackerClientMock")
    client.should_receive(:deliver).with(deliver_options[:commits])
    GitHooks::Notifier::TrackerClient.should_receive(:new).with({:api_key => "MY_API_KEY"}).and_return(client)
    
    GitHooks::Notifier::TrackerClient.deliver(deliver_options)
  end
  
end