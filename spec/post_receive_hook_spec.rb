require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PostReceiveHook" do
  
  it "should should read arguments given by Git from stdin" do
    STDIN.expects(:gets).times(2).returns("old_sha new_sha refs/head/master\n").then.returns(nil)

    post_receive_hook = GitHooks::PostReceiveHook.new
    arguments = post_receive_hook.read_arguments_from_stdin
    arguments.should == ["old_sha", "new_sha", "refs/head/master"]
  end
  
  it "should promote the received commits through jabber to the galaxy_cats" do
    post_receive_hook = GitHooks::PostReceiveHook.new

    post_receive_hook.should_receive(:read_arguments_from_stdin).
      and_return(["old_sha", "new_sha", "refs/head/master"])

    GitHooks::GitAdapter.any_instance.
      expects(:find_commits_since_last_receive).
      with("old_sha", "new_sha", "refs/head/master").
      returns(commits = [mock("Commit")])
      
    GitHooks::Notifier.should_receive(:jabber).with(:commits => commits, :to => :galaxy_cats)
    
    post_receive_hook.run
  end
  
end