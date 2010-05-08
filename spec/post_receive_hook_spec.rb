require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PostReceiveHook" do
  
  it "should should read arguments given by Git from stdin" do
    STDIN.expects(:gets).times(2).returns("old_sha new_sha refs/head/master\n").then.returns(nil)

    post_receive_hook = GitHooks::PostReceiveHook.new
    arguments = post_receive_hook.read_arguments_from_stdin
    arguments.should == ["old_sha", "new_sha", "refs/head/master"]
  end
  
  it "should promote the received commits to all registered post_receive hooks" do
    post_receive_hook = GitHooks::PostReceiveHook.new

    post_receive_hook.should_receive(:read_arguments_from_stdin).
      and_return(["old_sha", "new_sha", "refs/head/master"])

    GitHooks::GitAdapter.any_instance.
      expects(:find_commits_since_last_receive).
      with("old_sha", "new_sha", "refs/head/master").
      returns(commits = [mock("Commit")])

    jabber_hook = mock("HookMock")
    jabber_hook.should_receive(:hook_class).and_return(GitHooks::Notifier::JabberClient)
    jabber_hook.should_receive(:options).and_return({:other_jabber_option => "Option"})
    
    post_receive_hooks = [jabber_hook]
    
    GitHooks.config.should_receive(:post_receive_hooks).and_return(post_receive_hooks)
    
    GitHooks::Notifier::JabberClient.should_receive(:deliver).with({:other_jabber_option => "Option", :commits => commits})
    
    post_receive_hook.run
  end
  
end