require 'uri'

require 'vagrant/util/downloader'
require 'vagrant-s3auth-mfa/util'

S3Auth = VagrantPlugins::S3Auth

module Vagrant
  module Util
    class Downloader
      def s3auth_credential_source
        credential_provider = S3Auth::Util.s3_credential_provider
        case credential_provider
        when ::Aws::Credentials
          I18n.t(
            'vagrant_s3auth.downloader.env_credential_provider',
            access_key: credential_provider.credentials.access_key_id,
            env_var: S3Auth::Util::AWS_ACCESS_KEY_ENV_VARS.find { |k| ENV.key?(k) }
          )
        when ::Aws::SharedCredentials
          I18n.t(
            'vagrant_s3auth.downloader.profile_credential_provider',
            access_key: credential_provider.credentials.access_key_id,
            profile: credential_provider.profile_name
          )
        when String
          I18n.t(
            'vagrant_s3auth.downloader.profile_credential_config',
            profile: credential_provider
          )
        end
      end

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

        @ui.detail(s3auth_credential_source) if @ui

        url.replace(S3Auth::Util.s3_url_for(method, s3_object).to_s)

        execute_curl_without_s3auth(options, subprocess_options, &data_proc)
      rescue Errors::DownloaderError => e
        if e.message =~ /403 Forbidden/
          e.message << "\n\n"
          e.message << I18n.t('vagrant_s3auth.errors.box_download_forbidden',
            bucket: s3_object && s3_object.bucket.name)
        end
        raise
      rescue ::Aws::Errors::MissingCredentialsError
        raise S3Auth::Errors::MissingCredentialsError
      rescue ::Aws::Errors::ServiceError => e
        raise S3Auth::Errors::S3APIError, error: e
      rescue ::Seahorse::Client::NetworkingError => e
        # Vagrant ignores download errors during e.g. box update checks
        # because an internet connection isn't necessary if the box is
        # already downloaded. Vagrant isn't expecting AWS's
        # Seahorse::Client::NetworkingError, so we cast it to the
        # DownloaderError Vagrant expects.
        raise Errors::DownloaderError, message: e
      end

      def execute_curl_with_s3auth(options, subprocess_options, &data_proc)
        execute_curl_without_s3auth(options, subprocess_options, &data_proc)
      rescue Errors::DownloaderError => e
        # Ensure the progress bar from the just-failed request is cleared.
        @ui.clear_line if @ui

        s3auth_download(options, subprocess_options, &data_proc) || (raise e)
      end

      alias execute_curl_without_s3auth execute_curl
      alias execute_curl execute_curl_with_s3auth
    end
  end
end
