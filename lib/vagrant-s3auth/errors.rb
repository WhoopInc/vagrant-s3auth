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
    end
  end
end
