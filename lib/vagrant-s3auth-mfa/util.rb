require 'aws-sdk'
require 'log4r'
require 'net/http'
require 'uri'
require 'aws_config'

module VagrantPlugins
  module S3Auth
    module Util
      S3_HOST_MATCHER = /^((?<bucket>[[:alnum:]\-\.]+).)?s3([[:alnum:]\-\.]+)?\.amazonaws\.com$/

      # The list of environment variables that the AWS Ruby SDK searches
      # for access keys. Sadly, there's no better way to determine which
      # environment variable the Ruby SDK is using without mirroring the
      # logic ourself.
      #
      # See: https://github.com/aws/aws-sdk-ruby/blob/ab0eb18d0ce0a515254e207dae772864c34b048d/aws-sdk-core/lib/aws-sdk-core/credential_provider_chain.rb#L42
      AWS_ACCESS_KEY_ENV_VARS = %w[AWS_ACCESS_KEY_ID AMAZON_ACCESS_KEY_ID AWS_ACCESS_KEY].freeze

      DEFAULT_REGION = 'us-east-1'.freeze

      LOCATION_TO_REGION = Hash.new { |_, key| key }.merge(
        '' => DEFAULT_REGION,
        'EU' => 'eu-west-1'
      )

      class NullObject
        def method_missing(*) # rubocop:disable Style/MethodMissing
          nil
        end
      end

      def self.s3_client(region = DEFAULT_REGION)
        unless ENV['AWS_CONFIG_PROFILE'].nil?
          config = AWSConfig[ENV['AWS_CONFIG_PROFILE']]
          set_credentials_from_profile(config) if ::Aws.config.empty?
        end
        ::Aws::S3::Client.new(region: region)
      end

      def self.s3_resource(region = DEFAULT_REGION)
        ::Aws::S3::Resource.new(client: s3_client(region))
      end

      def self.s3_object_for(url, follow_redirect = true)
        url = URI(url)

        if url.scheme == 's3'
          bucket = url.host
          key = url.path[1..-1]
          raise Errors::MalformedShorthandURLError, url: url unless bucket && key
        elsif match = S3_HOST_MATCHER.match(url.host)
          components = url.path.split('/').delete_if(&:empty?)
          bucket = match['bucket'] || components.shift
          key = components.join('/')
        end

        if bucket && key
          s3_resource(get_bucket_region(bucket)).bucket(bucket).object(key)
        elsif follow_redirect
          response = Net::HTTP.get_response(url) rescue nil
          if response.is_a?(Net::HTTPRedirection)
            s3_object_for(response['location'], false)
          end
        end
      end

      def self.s3_url_for(method, s3_object)
        s3_object.presigned_url(method, expires_in: 60 * 10)
      end

      def self.get_bucket_region(bucket)
        LOCATION_TO_REGION[
          s3_client.get_bucket_location(bucket: bucket).location_constraint
        ]
      rescue ::Aws::S3::Errors::AccessDenied
        raise Errors::BucketLocationAccessDeniedError, bucket: bucket
      end

      def self.s3_credential_provider
        # Providing a NullObject here is the same as instantiating a
        # client without specifying a credentials config, like we do in
        # `self.s3_client`.
          unless ENV['AWS_CONFIG_PROFILE'].nil?
            ENV['AWS_CONFIG_PROFILE']
          else
            ::Aws::CredentialProviderChain.new(NullObject.new).resolve
          end
      end

      def self.set_credentials_from_profile(region = DEFAULT_REGION, config)
        creds = ::Aws::Credentials.new(
          config.aws_access_key_id,
          config.aws_secret_access_key
        )
        sts_client = ::Aws::STS::Client.new(
          credentials: creds 
        )
        if config.respond_to?(:mfa_serial)
          print 'Enter AWS MFA token: '
          token_code = STDIN.noecho(&:gets).chomp
          creds = sts_client.get_session_token(
            duration_seconds: 900,
            serial_number: config.mfa_serial,
            token_code: token_code
          )
          sts_client = ::Aws::STS::Client.new(
            access_key_id: creds.credentials.access_key_id,
            secret_access_key: creds.credentials.secret_access_key,
            session_token: creds.credentials.session_token
          )
        end
        if config.respond_to?(:role_arn)
        creds = ::Aws::AssumeRoleCredentials.new(
          client: sts_client,
          role_arn: config.role_arn,
          role_session_name: "#{ENV['USER']}-#{Time.now.utc.iso8601.tr!('-:', '_')}"
        )
        end
        ::Aws.config.update(
          region: config.region,
          credentials: creds
        )
      rescue StandardError => e
          raise Errors::SetCredentialsFromProfileError, profile: config.name, error: e
      end
    end
  end
end
