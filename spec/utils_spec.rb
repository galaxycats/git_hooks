require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Utils" do
  
  it "should find out the hostname" do
    GitHooks::Utils.hostname.should_not be(nil)
  end
  
end