require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GitHooks" do
  it "should run a hook identified by a symbol" do
    post_receive_hook_mock = mock("PostReceiveHook")
    post_receive_hook_mock.should_receive(:run)
    GitHooks::PostReceiveHook.should_receive(:new).and_return(post_receive_hook_mock)
    
    GitHooks.run_hook(:post_receive)
  end
end
