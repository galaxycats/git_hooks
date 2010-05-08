module GitHooks
  module Utils

    class Config
      include Singleton
      
      class HookWrapper
        
        attr_reader :options
        
        def initialize(options)
          @hook_class_name = options.keys.first
          @options = options.values.first
        end
        
        def hook_class
          @hook_class ||= "GitHooks::Notifier::#{@hook_class_name.to_s.camelize}Client".constantize
        end
        
      end
      
      attr_reader :config
      
      def initialize(config_file = "~/.git_hooks_config")
        @config = YAML.load_file(File.expand_path(config_file))
      rescue
        GitHooks::Logger.error("Config File '#{config_file}' couldn't be loaded!")
        raise "Config File '#{config_file}' couldn't be loaded!"
      end
      
      def method_missing(hook_name, *args, &blk)
        if hook_definitions = config[hook_name]

          hooks = hook_definitions.map { |hook_definition| HookWrapper.new(hook_definition) }
          instance_variable_set("@#{hook_name}", hooks)
          
          instance_eval <<-RUBY
          def #{hook_name}
            @#{hook_name}
          end
          RUBY
          
          send(hook_name)
        else
          super
        end
      end
      
    end

  end
end
