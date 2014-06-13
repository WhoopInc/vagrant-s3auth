begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant S3Auth plugin must be run within Vagrant.'
end

if Vagrant::VERSION < '1.5.0'
  raise 'The Vagrant AWS plugin is only compatible with Vagrant 1.5+'
end

require_relative 'errors'
require_relative 'extensions'

module VagrantPlugins
  module S3Auth
    class Plugin < Vagrant.plugin(2)
      name 's3auth'

      description <<-DESC
        Use versioned Vagrant boxes with S3 authentication.
      DESC

      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', VagrantPlugins::S3Auth.source_root)
        I18n.reload!
      end
    end
  end
end
