require 'vagrant'

module VagrantPlugins
  module S3Auth
    module Errors
      class VagrantS3AuthError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_s3auth.errors')
      end

      class MissingCredentialsError < VagrantS3AuthError
        error_key(:missing_credentials)
      end

      class MalformedShorthandURLError < VagrantS3AuthError
        error_key(:malformed_shorthand_url)
      end

      class BucketLocationAccessDeniedError < VagrantS3AuthError
        error_key(:bucket_location_access_denied_error)
      end

      class S3APIError < VagrantS3AuthError
        error_key(:s3_api_error)
      end

      class SetCredentialsFromProfileError < VagrantS3AuthError
        error_key(:set_credentials_from_profile_error)
      end
    end
  end
end
