require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "JabberClient" do
  
  describe "Buddy" do
    
    it "should have a JID and a roster reference" do
      buddy = GitHooks::Notifier::JabberClient::Buddy.new("lela.starr@jabber.org", mock("RosterMock"))
      buddy.jid.should be_a_kind_of(Jabber::JID)
    end
    
    it "should should know if already subscribed" do
      roster_mock = mock("RosterMock")

      roster_mock.should_receive(:[]).with(Jabber::JID.new("lela.starr@jabber.org")).and_return(mock("RosterItemMock", :subscription => :both))
      buddy = GitHooks::Notifier::JabberClient::Buddy.new("lela.starr@jabber.org", roster_mock)
      buddy.subscribed?.should be(true)
      
      roster_mock.should_receive(:[]).with(Jabber::JID.new("lela.starr@jabber.org")).and_return(mock("RosterItemMock", :subscription => :none))
      buddy = GitHooks::Notifier::JabberClient::Buddy.new("lela.starr@jabber.org", roster_mock)
      buddy.subscribed?.should be(false)
    end
    
  end
  
  it "should initialize with a XMPP client" do
    Jabber::JID.should_receive(:new).and_return(jid_mock = mock("JIDMock"))
    Jabber::Client.should_receive(:new).with(jid_mock).and_return(client_mock = mock("ClientMock"))
    client_mock.should_receive(:connect).with("talk.google.com")
    client_mock.should_receive(:auth)
    
    jabber_client = GitHooks::Notifier::JabberClient.new
  end
  
  it "should have different groups to send messages to" do
    jabber_config = {
      "jabber" => {
        "recipients" => {:planetexpress => ["bender.rodriguez@planetexpress.com"]}
      },
    }
    
    config_mock = mock("Config")
    config_mock.should_receive(:notifier).and_return(jabber_config)
    
    GitHooks::Utils.should_receive(:config).and_return(config_mock)
    
    GitHooks::Notifier::JabberClient::Buddy.should_receive(:new).and_return(mock("Buddy"))
    
    GitHooks::Notifier::JabberClient.any_instance.stubs(:init_jabber_backend!)
    jabber_client = GitHooks::Notifier::JabberClient.new
    jabber_client.should_receive(:roster)
    jabber_client.groups(:planetexpress).should have_at_least(1).things
  end
  
  it "should have a list of buddies" do
    GitHooks::Notifier::JabberClient.any_instance.stubs(:init_jabber_backend!)
    jabber_client = GitHooks::Notifier::JabberClient.new
    jabber_client.should_receive(:roster).
      at_least(2).times.
      and_return(roster_mock = mock("RosterMock"))

    GitHooks::Notifier::JabberClient::Buddy.should_receive(:new).
      with("lela.starr@jabber.org", roster_mock).
      and_return(lela_starr = mock("BuddyMock"))

    roster_mock.should_receive(:items).
      and_return({:jabber_internal => mock("RosterItem", :jid => "lela.starr@jabber.org")})
    
    jabber_client.buddies.should == [lela_starr]
  end
  
  it "should create a message out of a bunch of commits" do
    GitHooks::Notifier::JabberClient.any_instance.stubs(:init_jabber_backend!)
    jabber_client = GitHooks::Notifier::JabberClient.new

    commit = mock("CommitMock")
    commit.should_receive(:id).and_return("c1be3c82cafc755754ee2247ec8dae1e6a64857f")
    commit.should_receive(:short_message).and_return("This was a simple test commit.")
    commit.should_receive(:author).and_return(mock("Author", :name => "Dirk Breuer"))
    
    commits = mock("CommitsMock")
    commits.should_receive(:ref_name).and_return("master")
    commits.should_receive(:repo_name).and_return("git_hooks")
    commits.should_receive(:each).and_yield(commit)
    commits.should_receive(:size).and_return(1)
    
    jabber_client.create_message(commits)
  end
  
  it "should request a recipient for authorization if she is not a subscribed buddy" do
    GitHooks::Notifier::JabberClient.any_instance.stubs(:init_jabber_backend!)
    jabber_client = GitHooks::Notifier::JabberClient.new
    jabber_client.should_receive(:backend).and_return(mock("JabberBackend", :send => true))
    jabber_client.should_receive(:groups).and_return(nil)

    jabber_client.should_receive(:roster).and_return(roster_mock = mock("RosterMock"))
    
    GitHooks::Notifier::JabberClient::Buddy.should_receive(:new).
      with("lela.starr@jabber.org", roster_mock).
      and_return(buddy = mock("BuddyMock", :subscribed? => false, :jid => "lela.starr@jabber.org"))
      
    jabber_client.should_receive(:request_authorization_of).with(buddy)
    
    jabber_client.send_message_to "My testing message", "lela.starr@jabber.org"
  end
  
  it "should send the notification based on the given options" do
    GitHooks::Notifier::JabberClient.any_instance.stubs(:init_jabber_backend!)
    jabber_client = GitHooks::Notifier::JabberClient.new
    commits = [mock("Commit")]
    jabber_client.should_receive(:create_message).with(commits).and_return(message = "Message")
    jabber_client.should_receive(:send_message_to).with(message, :galaxy_cats)
    jabber_client.send(:commits => commits, :to => :galaxy_cats)
  end
  
end