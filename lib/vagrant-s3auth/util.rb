require 'aws-sdk'
require 'log4r'
require 'net/http'
require 'uri'

module VagrantPlugins
  module S3Auth
    module Util
      S3_HOST_MATCHER = /^((?<bucket>[[:alnum:]\-\.]+).)?s3([[:alnum:]\-\.]+)?\.amazonaws\.com$/

      DEFAULT_REGION = 'us-east-1'

      LOCATION_TO_REGION = Hash.new { |_, key| key }.merge(
        '' => DEFAULT_REGION,
        'EU' => 'eu-west-1'
      )

      def self.s3_client(region = DEFAULT_REGION)
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
        raise Errors::BucketLocationAccessDeniedError,
          bucket: bucket,
          access_key: ENV['AWS_ACCESS_KEY_ID']
      end
    end
  end
end
