#!/usr/bin/env ruby

require 'bundler/setup'
require 'aws-sdk'

require_relative 'support'

[REGION_STANDARD, REGION_NONSTANDARD].each do |region|
  s3 = Aws::S3::Resource.new(region: region)

  buckets = if ARGV.include?('--all')
              s3.buckets.select do |b|
                b.name.include?('vagrant-s3auth-mfa.com') && b.name.include?(region)
              end
            else
              [s3.bucket("#{region}.#{BUCKET}")]
            end

  buckets.each { |b| b.delete! if b.exists? }
end

atlas = Atlas.new(ATLAS_TOKEN, ATLAS_USERNAME)
atlas.delete_box(ATLAS_BOX_NAME)
