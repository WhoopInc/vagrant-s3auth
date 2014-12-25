## 1.0.2

**Unreleased**

Enhancements:

* provide better error messages when S3 API requests are denied [#9]
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
