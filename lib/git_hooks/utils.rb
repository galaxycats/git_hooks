module GitHooks
  module Utils

    class <<self
      def hostname
        `hostname -s`.strip
      end
      
      def config
        Config.instance
      end
    end
    
    class Config
      include Singleton
      
      attr_reader :config
      
      def initialize(config_file = "~/.git_hooks_config")
        @config = YAML.load_file(File.expand_path(config_file))
      rescue
        GitHooks::Logger.error("Config File '#{config_file}' couldn't be loaded!")
        raise "Config File '#{config_file}' couldn't be loaded!"
      end
      
      def method_missing(meth, *args, &blk)
        if top_level_config = config[meth.to_s]
          top_level_config
        else
          super
        end
      end
      
    end

  end
end
