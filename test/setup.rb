#!/usr/bin/env ruby

require 'bundler/setup'
require 'aws-sdk'

require_relative 'support'

ROOT = Pathname.new(File.dirname(__FILE__))

box_urls = [REGION_STANDARD, REGION_NONSTANDARD].flat_map do |region|
  s3 = Aws::S3::Resource.new(region: region)
  bucket = s3.create_bucket(bucket: "#{region}.#{BUCKET}")

  [BOX_BASE, 'public-' + BOX_BASE].flat_map do |box_name|
    box = bucket.object("#{box_name}.box")
    box.upload_file(ROOT + Pathname.new("box/#{box_name}.box"))
    box.acl.put(acl: 'public-read') if box_name.start_with?('public')

    metadata_string = format(File.read(ROOT + Pathname.new("box/#{box_name}")),
      box_url: box.public_url)

    metadata = bucket.object(box_name)
    metadata.put(body: metadata_string, content_type: 'application/json')
    metadata.acl.put(acl: 'public-read') if box_name.start_with?('public')

    box.public_url
  end
end

atlas = Atlas.new(ATLAS_TOKEN, ATLAS_USERNAME)
atlas.create_box(ATLAS_BOX_NAME)
atlas.create_version(ATLAS_BOX_NAME, '1.0.1')
atlas.create_provider(ATLAS_BOX_NAME, '1.0.1', box_urls.sample)
atlas.release_version(ATLAS_BOX_NAME, '1.0.1')
