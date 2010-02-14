module GitHooks
  module Utils

    class <<self
      def hostname
        `hostname -s`.strip
      end
    end

  end
end
