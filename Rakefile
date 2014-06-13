require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'

Dir.chdir(File.expand_path('../', __FILE__))

Bundler::GemHelper.install_tasks

RuboCop::RakeTask.new(:lint)

task default: %w(lint)
