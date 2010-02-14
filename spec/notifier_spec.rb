require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Notifier" do
  
  it "should send notification through jabber" do
    options_for_notifier = mock("NotifierOptions")
    
    jabber_client = mock("JabberClientMock")
    jabber_client.should_receive(:send).with(options_for_notifier)
    GitHooks::Notifier::JabberClient.should_receive(:new).and_return(jabber_client)
    
    GitHooks::Notifier.jabber(options_for_notifier)
  end
  
end