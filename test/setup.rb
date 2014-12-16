#!/usr/bin/env ruby

require 'bundler/setup'
require 'aws'

require_relative 'support'

ROOT = Pathname.new(File.dirname(__FILE__))

box_urls = [REGION_STANDARD, REGION_NONSTANDARD].map do |region|
  s3 = AWS::S3.new(region: region)
  bucket = s3.buckets.create("#{region}.#{BUCKET}")

  box = bucket.objects["#{BOX_BASE}.box"]
  box.write(ROOT + Pathname.new("box/#{BOX_BASE}.box"))
  box.public_url

  metadata_string = File.read(ROOT + Pathname.new("box/#{BOX_BASE}")) % {
    box_url: box.public_url
  }

  metadata = bucket.objects[BOX_BASE]
  metadata.write(metadata_string, content_type: 'application/json')
  metadata.acl = :public_read

  box.public_url
end

atlas = Atlas.new(ATLAS_TOKEN, ATLAS_USERNAME)
atlas.create_box(ATLAS_BOX_NAME)
atlas.create_version(ATLAS_BOX_NAME, '1.0.1')
atlas.create_provider(ATLAS_BOX_NAME, '1.0.1', box_urls.sample)
atlas.release_version(ATLAS_BOX_NAME, '1.0.1')
