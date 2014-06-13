require 'uri'

require 'vagrant/util/downloader'
require 'vagrant-s3auth/util/authenticator'

module Vagrant
  module Util
    class Downloader
      def execute_curl_with_s3(options, subprocess_options, &data_proc)
        begin
          url = URI.parse(@source)
        rescue URI::InvalidURIError
          @logger.info("s3auth: Ignoring unparsable URL: #{url}")
        end

        if url && s3_url?(url)
          @logger.info("s3auth: Signing S3 URL: #{url}")

          method = options.any? { |o| o == '-I' } ? 'HEAD' : 'GET'
          headers = VagrantPlugins::S3Auth::Util::Authenticator.sign(url, method)

          headers.each do |name, value|
            options << '-H' << "#{name}: #{value}"
          end
        end

        execute_curl_without_s3(options, subprocess_options, &data_proc)
      end

      def s3_url?(url)
        url.host =~ VagrantPlugins::S3Auth::S3_HOST_MATCHER
      end

      alias_method :execute_curl_without_s3, :execute_curl
      alias_method :execute_curl, :execute_curl_with_s3
    end
  end
end
