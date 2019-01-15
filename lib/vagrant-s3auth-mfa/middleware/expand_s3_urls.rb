require 'uri'

module VagrantPlugins
  module S3Auth
    class ExpandS3Urls
      def initialize(app, _)
        @app = app
      end

      def call(env)
        env[:box_urls].map! do |url_string|
          url = URI(url_string)

          if url.scheme == 's3'
            bucket = url.host
            key = url.path[1..-1]
            raise Errors::MalformedShorthandURLError, url: url unless bucket && key
            next "http://s3-placeholder.amazonaws.com/#{bucket}/#{key}"
          end

          url_string
        end

        @app.call(env)
      end
    end
  end
end
