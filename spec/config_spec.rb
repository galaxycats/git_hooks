require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Utils" do
  
  describe "Config" do
    before(:each) do
      Singleton.__init__(GitHooks::Utils::Config)
    end
    
    it "should have read from a config file located in the home directory" do
      File.should_receive(:expand_path).with("~/.git_hooks_config").and_return(path_to_config = "/Users/dbreuer/.git_hooks_config")
      YAML.should_receive(:load_file).with(path_to_config).and_return({:post_receive_hooks => [{:jabber => {:jid => "jabber@example.com", :password => "password"}}]})
      
      GitHooks::Utils.config
    end
    
    it "should return all available hooks as an array of hook wrapper classes" do
      mocked_config = {
        :post_receive_hooks => [
          {
            :jabber => {
              :jid        => "jabber@example.com",
              :password   => "password",
              :recipients => [
                "bender.rodriguez@planetexpress.com"
              ]
            }
          },
          {
            :tracker => {
              :api_key => "fjan4cru903rc023ndfv0"
            }
          }
        ]
      }
      
      GitHooks::Utils::Config.instance.should_receive(:config).and_return(mocked_config)
      
      GitHooks::Utils.config.post_receive_hooks.each do |hook|
        hook.should be_a_kind_of(GitHooks::Utils::Config::HookWrapper)
      end
    end
    
    describe "HookWrapper" do
      
      before(:each) do
        hook_options = {
          :jabber => {
            :jid        => "jabber@example.com",
            :password   => "password",
            :recipients => [
              "bender.rodriguez@planetexpress.com"
            ]
          }
        }

        @hook_wrapper = GitHooks::Utils::Config::HookWrapper.new(hook_options)
      end
      
      it "should know its backing class" do
        @hook_wrapper.hook_class.should == GitHooks::Notifier::JabberClient
      end
      
      it "should know the options for this hook" do
        expected_options = {
          :jid        => "jabber@example.com",
          :password   => "password",
          :recipients => [
            "bender.rodriguez@planetexpress.com"
          ]
        }
        
        @hook_wrapper.options.should == expected_options
      end
      
    end
    
  end
  
end