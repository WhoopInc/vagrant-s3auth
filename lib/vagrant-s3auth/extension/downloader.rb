require 'uri'

require 'vagrant/util/downloader'
require 'vagrant-s3auth/util'

S3Auth = VagrantPlugins::S3Auth

module Vagrant
  module Util
    class Downloader
      def s3auth_download(options, subprocess_options, &data_proc)
        # The URL sent to curl is always the last argument. We have to rely
        # on this implementation detail because we need to hook into both
        # HEAD and GET requests.
        url = options.last

        s3_object = S3Auth::Util.s3_object_for(url)
        return unless s3_object

        @logger.info("s3auth: Discovered S3 URL: #{@source}")
        @logger.debug("s3auth: Bucket: #{s3_object.bucket.name.inspect}")
        @logger.debug("s3auth: Key: #{s3_object.key.inspect}")

        method = options.any? { |o| o == '-I' } ? :head : :get

        @logger.info("s3auth: Generating signed URL for #{method.upcase}")

        url.replace(S3Auth::Util.s3_url_for(method, s3_object).to_s)

        execute_curl_without_s3auth(options, subprocess_options, &data_proc)
      rescue Errors::DownloaderError => e
        if e.message =~ /403 Forbidden/
          e.message << "\n\n"
          e.message << I18n.t('vagrant_s3auth.errors.box_download_forbidden',
            access_key: ENV['AWS_ACCESS_KEY_ID'],
            bucket: s3_object && s3_object.bucket.name)
        end
        raise
      rescue ::Aws::Errors::MissingCredentialsError
        raise S3Auth::Errors::MissingCredentialsError
      rescue ::Aws::Errors::ServiceError => e
        raise S3Auth::Errors::S3APIError, error: e
      end

      def execute_curl_with_s3auth(options, subprocess_options, &data_proc)
        execute_curl_without_s3auth(options, subprocess_options, &data_proc)
      rescue Errors::DownloaderError => e
        s3auth_download(options, subprocess_options, &data_proc) || (raise e)
      end

      alias_method :execute_curl_without_s3auth, :execute_curl
      alias_method :execute_curl, :execute_curl_with_s3auth
    end
  end
end
