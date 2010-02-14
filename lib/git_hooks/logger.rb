require 'logger'

module GitHooks
  class Logger
    include Singleton

    class <<self
      def method_missing(meth, *args, &blk)
        if instance.logger.respond_to? meth
          instance.logger.send(meth, *args)
        else
          super
        end
      end
    end

    attr_reader :logger

    def initialize
      @logger = ::Logger.new("/tmp/git_hooks.log")
    end
  end
end