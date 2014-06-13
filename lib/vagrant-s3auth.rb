require 'pathname'

require 'vagrant-s3auth/plugin'

module VagrantPlugins
  module S3Auth
    S3_HOST         = 's3.amazonaws.com'
    S3_HOST_MATCHER = /^s3([[:alnum:]\-\.]+)?\.amazonaws\.com$/
    BOX_URL_MATCHER = %r{^s3://(?<bucket>[[:alnum:]\-\.]+)(?<resource>.*)/?}

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
