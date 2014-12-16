# Testing

No unit testing, since the project is so small. But a full suite of acceptance
tests that run using [Bats: Bash Automated Testing System][bats]! Basically, the
acceptance tests run `vagrant box add S3_URL` with a bunch of S3 URLs and box
types, and assert that everything works!

See [the .travis.yml CI configuration](.travis.yml) for a working example.

## Environment variables

You'll need to export the below. Recommended values included when not sensitive.

```bash
# AWS credentials with permissions to create S3 buckets
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

# Atlas (Vagrant Cloud) API credentials
export ATLAS_USERNAME="vagrant-s3auth"
export ATLAS_TOKEN

# Base name of bucket. Must be unique.
export VAGRANT_S3AUTH_BUCKET="testing.vagrant-s3auth.com"

# If specified as 'metadata', will upload 'box/metadata' and 'box/metadata.box'
# to each S3 bucket
export VAGRANT_S3AUTH_BOX_BASE="minimal"

# Base name of Atlas (Vagrant Cloud) box. Atlas boxes can never re-use a once
# existing name, so include a timestamp or random string in the name.
export VAGRANT_S3AUTH_ATLAS_BOX_NAME="vagrant-s3auth-192458"

# Additional S3 region to use in testing. US Standard is always used.
export VAGRANT_S3AUTH_REGION_NONSTANDARD="eu-west-1"
```

[bats]: https://github.com/sstephenson/bats

## Running tests

You'll need [Bats][bats] installed! Then:

```bash
# export env vars as described
$ test/setup.rb
$ rake test
# hack hack hack
$ rake test
$ test/cleanup.rb
```

## Scripts

### test/setup.rb

Creates two S3 buckets—one in US Standard (`us-east-1`) and one in
`$VAGRANT_S3AUTH_REGION_NONSTANDARD`, both with the contents of the box
directory.

Then creates an Atlas (Vagrant Cloud) box with one version with one VirtualBox
provider that points to one of the S3 boxes at random.

### test/cleanup.rb

Destroys S3 buckets and Atlas box.

## run.bats

Attempts to `vagrant box add` the boxes on S3 in every way possible.
