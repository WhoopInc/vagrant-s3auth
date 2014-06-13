require 'base64'
require 'cgi'
require 'log4r'
require 'openssl'
require 'uri'

module VagrantPlugins
  module S3Auth
    module Action
      class AuthenticateBoxUrl
        def initialize(app, _env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_s3auth::action::authenticate_box_url')
          @access_key = ENV['AWS_ACCESS_KEY_ID']
          @secret_key = ENV['AWS_SECRET_ACCESS_KEY']
        end

        def call(env)
          env[:box_urls].map! do |url_string|
            begin
              url = URI.parse(url_string)
            rescue URI::InvalidURIError
              next url_string
            end

            unless s3_url?(url)
              @logger.debug("Skipping non-S3 host: #{url}")
              next url_string
            end

            # Vagrant makes a HEAD request for metadata. S3 doesn't support
            # query-string authentication on HEAD requests, so skip signing. We
            # need to provide a different "authenticated" URL, though, or
            # Vagrant will think the box doesn't require authentication,
            # and won't request an authenticated URL for the box itself.
            unless box_url?(url)
              @logger.debug("Munging S3 metadata URL: #{url}")
              next url_string + '?'
            end

            @logger.info("Signing URL for S3 box: #{url}")
            sign(url)
          end

          @app.call(env)
        end

        def sign(url)
          ensure_credentials

          expires = (Time.now + 20).to_i
          message = "GET\n\n\n#{expires}\n#{url.path}"
          signature = CGI.escape(Base64.strict_encode64(
            OpenSSL::HMAC.digest('sha1', @secret_key, message)))

          url.query = {
            'AWSAccessKeyId' => @access_key,
            'Expires'        => expires,
            'Signature'      => signature
          }.map { |k, v| "#{k}=#{v}" }.join('&')

          url.to_s
        end

        def ensure_credentials
          missing_variables = []
          missing_variables << 'AWS_ACCESS_KEY_ID' unless @access_key
          missing_variables << 'AWS_SECRET_ACCESS_KEY' unless @secret_key

          # rubocop:disable Style/GuardClause
          unless missing_variables.empty?
            raise Errors::MissingCredentialsError,
              missing_variables: missing_variables.join(', ')
          end
          # rubocop:enable Style/GuardClause
        end

        def s3_url?(url)
          url.host =~ S3_HOST_MATCHER
        end

        def box_url?(url)
          url.path.end_with?('.box')
        end
      end
    end
  end
end
