require 'uri'

module Vagrant
  module Action
    module Builtin
      class BoxAdd
        def call_with_s3(env)
          box_url = env[:box_url]

          # Non-iterable box_urls are Vagrant Cloud boxes, which we don't need
          # to handle.
          if box_url.respond_to?(:map!)
            box_url.map! do |url|
              if matched = VagrantPlugins::S3Auth::BOX_URL_MATCHER.match(url)
                @logger.info('Transforming S3 box URL: #{url}')
                s3_url(matched[:bucket], matched[:resource])
              else
                @logger.info("Not transforming non-S3 box: #{url}")
                url
              end
            end
          else
            @logger.debug('Box URL #{box_url.inspect} looks like a Vagrant "
              Cloud box, skipping S3 transformation...')
          end

          call_without_s3(env)
        end

        def s3_url(bucket, resource)
          URI::HTTPS.build(
            host: VagrantPlugins::S3Auth::S3_HOST,
            path: File.join('/', bucket, resource)).to_s
        end

        alias_method :call_without_s3, :call
        alias_method :call, :call_with_s3
      end
    end
  end
end
