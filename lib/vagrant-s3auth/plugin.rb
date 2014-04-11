begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant S3Auth plugin must be run within Vagrant.'
end

if Vagrant::VERSION < '1.5.0'
  raise 'The Vagrant AWS plugin is only compatible with Vagrant 1.5+'
end

require_relative 'action'
require_relative 'errors'

module VagrantPlugins
  module S3Auth
    class Plugin < Vagrant.plugin(2)
      name 's3auth'

      description <<-DESC
        Use versioned Vagrant boxes with S3 authentication.
      DESC

      action_hook 'authenticate-box-url', :authenticate_box_url do |hook|
        setup_i18n
        setup_logging

        hook.append(Action.authenticate_box_url)
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', VagrantPlugins::S3Auth.source_root)
        I18n.reload!
      end

      def self.setup_logging
        require 'log4r'

        level = nil
        begin
          level = Log4r.const_get(ENV['VAGRANT_LOG'].upcase)
        rescue NameError
          level = nil
        end

        if level
          logger = Log4r::Logger.new('vagrant_s3auth')
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
        end
      end
    end
  end
end
