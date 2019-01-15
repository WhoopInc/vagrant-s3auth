$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'vagrant-s3auth-mfa/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-s3auth-mfa'
  spec.version       = VagrantPlugins::S3Auth::VERSION
  spec.authors       = ['Nikhil Benesch']
  spec.email         = ['benesch@whoop.com']
  spec.summary       = '[VRTDev Fork]Private, versioned Vagrant boxes hosted on Amazon S3.'
  spec.homepage      = 'https://github.com/vrtdev/vagrant-s3auth-mfa'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(/spec/)
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 2.6.44'
  spec.add_dependency 'aws_config', '0.1.0'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'http', '~> 1.0.2'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 0.46'
end
