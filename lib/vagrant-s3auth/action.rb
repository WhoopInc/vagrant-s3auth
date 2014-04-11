require_relative 'action/authenticate_box_url'
require_relative 'action/box_add'

module VagrantPlugins
  module S3Auth
    module Action
      def self.authenticate_box_url
        Vagrant::Action::Builder.new.tap do |b|
          b.use AuthenticateBoxUrl
        end
      end
    end
  end
end
