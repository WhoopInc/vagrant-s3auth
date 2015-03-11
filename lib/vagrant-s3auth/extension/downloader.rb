require 'uri'

require 'vagrant/util/downloader'
require 'vagrant-s3auth/util'

S3Auth = VagrantPlugins::S3Auth

module Vagrant
  module Util
    class Downloader
      def execute_curl_with_s3(options, subprocess_options, &data_proc)
        # The URL sent to curl is always the last argument. We have to rely
        # on this implementation detail because we need to hook into both
        # HEAD and GET requests.
        url = options.last

        if s3_object = S3Auth::Util.s3_object_for(url)
          @logger.info("s3auth: Discovered S3 URL: #{@source}")
          @logger.debug("s3auth: Bucket: #{s3_object.bucket.name.inspect}")
          @logger.debug("s3auth: Key: #{s3_object.key.inspect}")

          method = options.any? { |o| o == '-I' } ? :head : :get

          @logger.info("s3auth: Generating signed URL for #{method.upcase}")

          url.replace(S3Auth::Util.s3_url_for(method, s3_object).to_s)
        end

        execute_curl_without_s3(options, subprocess_options, &data_proc)
      rescue Errors::DownloaderError => e
        if e.message =~ /403 Forbidden/
          e.message << "\n\n"
          e.message << I18n.t('vagrant_s3auth.errors.box_download_forbidden',
            access_key: ENV['AWS_ACCESS_KEY_ID'],
            bucket: s3_object && s3_object.bucket.name)
        end
        raise
      rescue ::AWS::Errors::MissingCredentialsError
        raise VagrantPlugins::S3Auth::Errors::MissingCredentialsError
      rescue ::AWS::Errors::Base => e
        raise VagrantPlugins::S3Auth::Errors::S3APIError, error: e
      end

      alias_method :execute_curl_without_s3, :execute_curl
      alias_method :execute_curl, :execute_curl_with_s3
    end
  end
end
