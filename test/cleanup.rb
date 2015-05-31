#!/usr/bin/env ruby

require 'bundler/setup'
require 'aws-sdk'

require_relative 'support'

[REGION_STANDARD, REGION_NONSTANDARD].each do |region|
  s3 = Aws::S3::Resource.new(region: region)
  bucket = s3.bucket("#{region}.#{BUCKET}")
  bucket.delete! if bucket.exists?
end

atlas = Atlas.new(ATLAS_TOKEN, ATLAS_USERNAME)
atlas.delete_box(ATLAS_BOX_NAME)
