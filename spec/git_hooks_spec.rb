require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GitHooks" do

  it "should run a hook identified by a symbol" do
    post_receive_hook_mock = mock("PostReceiveHook")
    post_receive_hook_mock.should_receive(:run)
    GitHooks::PostReceiveHook.should_receive(:new).and_return(post_receive_hook_mock)
    
    GitHooks.run_hook(:post_receive)
  end
  
  it "should provide access to a config instance" do
    GitHooks.config.should be_a_kind_of(GitHooks::Utils::Config)
  end
  
  it "should provide a setter for the config file path" do
    GitHooks.config_file = "/path/to/config.yml"
    GitHooks.config_file.should == "/path/to/config.yml"
  end

end
