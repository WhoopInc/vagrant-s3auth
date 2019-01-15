begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant S3Auth plugin must be run within Vagrant.'
end

require_relative 'errors'
require_relative 'extension/downloader'

module VagrantPlugins
  module S3Auth
    class Plugin < Vagrant.plugin('2')
      Vagrant.require_version('>= 1.5.1')

      name 's3auth'

      description <<-DESC
        Use versioned Vagrant boxes with S3 authentication.
      DESC

      action_hook(:s3_urls, :authenticate_box_url) do |hook|
        require_relative 'middleware/expand_s3_urls'
        hook.prepend(ExpandS3Urls)
      end
    end
  end
end
