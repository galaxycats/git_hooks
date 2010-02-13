require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GitAdapter" do
  it "should initialize with a Grit repository" do
    GitHooks::GitAdapter.should_receive(:find_git_root)
    Grit::Repo.should_receive(:new)
    
    git_adapter = GitHooks::GitAdapter.new
  end
  
  it "should find the Git root directory based on the current directory" do
    git_adapter = GitHooks::GitAdapter.new
    commits = git_adapter.find_commits_since_last_receive("7eb08614", "58c3455c")
    commits.size.should be(2)
    commits.ref_name.should == "master"
    commits.repo_name.should == "git_hooks"
  end
  
  it "should find commits since last commit" do
    Dir.should_receive(:pwd).and_return("/srv/example.com/git/repositories/git_hooks.git/hooks")
    git_root = GitHooks::GitAdapter.find_git_root
    git_root.should == "/srv/example.com/git/repositories/git_hooks.git"
    
    Dir.should_receive(:pwd).and_return("/home/dbreuer/projects/git_hooks/.git/hooks")
    git_root = GitHooks::GitAdapter.find_git_root
    git_root.should == "/home/dbreuer/projects/git_hooks/.git"
  end
end