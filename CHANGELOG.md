## Unreleased

**20 August 2015**

Enhancements:

* output the discovered AWS access key and its source (environment variable or
  profile) when downloading an authenticated S3 box ([#21])

Thanks, [@Daemoen][Daemoen]!

## 1.1.1

**6 August 2015**

Enhancements:

* bump dependencies to latest patch versions and dev dependencies to latest
  versions

## 1.1.0

**1 June 2015**

Enhancements:

* upgrade to AWS SDK v2 ([#15])
* recommend the use of the AWS SDK's centralized credential file ([#14])

Fixes:

* allow up to ten minutes of time skew ([#16])
* try an unauthenticated download before demanding AWS credentials ([#10])

Thanks, [@kimpepper][kimpepper] and [@companykitchen-dev][companykitchen-dev]!

## 1.0.3

**10 March 2015**

Fixes:

* fix namespace collisions with [vagrant-aws][vagrant-aws] ([#11])

Thanks, [@andres-rojas][andres-rojas]!


## 1.0.2

**25 December 2014**

Enhancements:

* provide better error messages when S3 API requests are denied ([#9])
* include IAM policy recommendations in README

## 1.0.1

**21 December 2014**

Enhancements:

* support bucket-in-host style S3 URLs to simplify usage instructions

Fixes:

* internal cleanup
* improved detection of incompatible Vagrant versions

## 1.0.0

**16 December 2014**

Enhancements:

* passes a complete acceptance test suite
* detects full and shorthand S3 URLs at all download stages

Fixes:

* automatically determines region for shorthand S3 URLs ([#1], [#7])

## 0.1.0

**13 June 2014**

Enhancements:

* support buckets hosted in any S3 region ([#1])

Fixes:

* properly authenticate requests for simple (non-metadata) S3 boxes ([#1])

## 0.0.2

**6 June 2014**

Enhancements:

* formally license under MIT

## 0.0.1

* initial release

[#1]: https://github.com/WhoopInc/vagrant-s3auth/issues/1
[#7]: https://github.com/WhoopInc/vagrant-s3auth/issues/7
[#9]: https://github.com/WhoopInc/vagrant-s3auth/issues/9
[#10]: https://github.com/WhoopInc/vagrant-s3auth/issues/10
[#11]: https://github.com/WhoopInc/vagrant-s3auth/pull/11
[#14]: https://github.com/WhoopInc/vagrant-s3auth/issues/14
[#15]: https://github.com/WhoopInc/vagrant-s3auth/issues/15
[#16]: https://github.com/WhoopInc/vagrant-s3auth/issues/16
[#21]: https://github.com/WhoopInc/vagrant-s3auth/issues/21

[Daemoen]: https://github.com/Daemoen
[andres-rojas]: https://github.com/andres-rojas
[companykitchen-dev]: https://github.com/companykitchen-dev
[kimpepper]: https://github.com/kimpepper

[vagrant-aws]: https://github.com/mitchellh/vagrant-aws
