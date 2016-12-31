$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'vagrant-s3auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-s3auth'
  spec.version       = VagrantPlugins::S3Auth::VERSION
  spec.authors       = ['Nikhil Benesch']
  spec.email         = ['benesch@whoop.com']
  spec.summary       = 'Private, versioned Vagrant boxes hosted on Amazon S3.'
  spec.homepage      = 'https://github.com/WhoopInc/vagrant-s3auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(/spec/)
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 2.2.10'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'http', '~> 1.0.2'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 0.46'
end
