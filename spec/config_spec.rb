require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Utils" do
  
  describe "Config" do
    before(:each) do
      Singleton.__init__(GitHooks::Utils::Config)
    end
    
    it "should have read from a config file located in the home directory" do
      File.should_receive(:expand_path).with("~/.git_hooks_config").and_return(path_to_config = "/Users/dbreuer/.git_hooks_config")
      YAML.should_receive(:load_file).with(path_to_config).and_return({"notifier" => {"jabber" => {"jid" => "jabber@example.com", "password" => "password"}}})
      
      GitHooks::Utils.config
    end
    
    it "should provide methods for the top level config elements" do
      mocked_config = {
        "notifier" => {
          "jabber" => {
            "jid" => "jabber@example.com",
            "password" => "password",
            "recipients" => [
              "bender.rodriguez@planetexpress.com"
            ]
          },
        },
        "tools" => {
          "pivotal_tracker" => {
            "api_key" => "fjan4cru903rc023ndfv0"
          }
        }
      }
      
      GitHooks::Utils::Config.instance.should_receive(:config).twice.and_return(mocked_config)
      
      GitHooks::Utils.config.notifier["jabber"].should equal(mocked_config["notifier"]["jabber"])
      GitHooks::Utils.config.tools.should equal(mocked_config["tools"])
    end
  end
  
end