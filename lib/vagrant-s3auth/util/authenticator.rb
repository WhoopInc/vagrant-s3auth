require 'base64'
require 'cgi'
require 'log4r'
require 'openssl'
require 'uri'

require 'vagrant/util/downloader'

module VagrantPlugins
  module S3Auth
    module Util
      class Authenticator
        def self.sign(url, method)
          new.sign(url, method)
        end

        def initialize
          @access_key = ENV['AWS_ACCESS_KEY_ID']
          @secret_key = ENV['AWS_SECRET_ACCESS_KEY']

          ensure_credentials
        end

        def sign(url, method)
          now = CGI.rfc1123_date(Time.now)
          message = "#{method}\n\n\n#{now}\n#{url.path}"
          signature = Base64.strict_encode64(
            OpenSSL::HMAC.digest('sha1', @secret_key, message))

          {
            date: now,
            authorization: "AWS #{@access_key}:#{signature}"
          }
        end

        protected

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
      end
    end
  end
end
