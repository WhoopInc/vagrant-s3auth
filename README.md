# vagrant-s3auth

Private, versioned Vagrant boxes hosted on Amazon S3.

## Installation

From the command line:

```bash
$ vagrant plugin install vagrant-s3auth
```

### Requirements

* [Vagrant][vagrant], v1.5.0+

## Usage

vagrant-s3auth will automatically convert S3 box URLs

```
s3://bucket.example.com/path/to/metadata
```

to URLs [signed with your AWS access key][aws-signed]:

```
https://s3.amazonaws.com/bucket.example.com/path/to/metadata?AWSAccessKeyId=
    AKIAIOSFODNN7EXAMPLE&Expires=1141889120&Signature=vjbyPxybdZaNmGa%2ByT272YEAiv4%3D
```

This means you can host your team's sensitive, private boxes on S3, and use your
developers' existing AWS credentials to securely grant access.

If you've already got your credentials stored in the appropriate environment
variables:

```ruby
# Vagrantfile

Vagrant.configure('2') do |config|
  config.vm.box     = 'simple-secrets'
  config.vm.box_url = 's3://example.com/secret.box'
end
```

### Configuration

#### AWS credentials

AWS credentials are read from the standard environment variables
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

If you need to obtain credentials from elsewhere, drop a block like the
following at the top of your Vagrantfile:

```ruby
creds = File.read(File.expand_path('~/.company-aws-creds')).lines
ENV['AWS_ACCESS_KEY_ID']     = creds[0]
ENV['AWS_SECRET_ACCESS_KEY'] = creds[1]
```


#### Simple boxes

Simply point your `box_url` at Amazon S3:

```ruby
Vagrant.configure('2') do |config|
  config.vm.box     = 'simple-secrets'
  config.vm.box_url = 'https://s3.amazonaws.com/bucket.example.com/secret.box'
end
```

Note that your URL must be of the form

```
https://s3.amazonaws.com/bucket/resource
```

Other valid forms of S3 URLs (`bucket.s3.amazonaws.com/resource.box`, etc.) will
not be detected by vagrant-s3auth.

As shorthand, `s3://` URLs will be automatically transformed. This is equivalent
to the above:

```ruby
Vagrant.configure('2') do |config|
  config.vm.box     = 'simple-secrets'
  config.vm.box_url = 's3://example.com/secret.box'
end
```

**Note:** Simple box URLs must end in `.box`, or they'll be interpreted as
[metadata boxes](#metadata-boxes).

#### Vagrant Cloud

Boxes on [Vagrant Cloud][vagrant-cloud] have support for versioning, multiple
providers, and a GUI management tool. If you've got a box version on Vagrant
Cloud.

Then just configure your Vagrantfile like normal:

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'examplecorp/secrets'
end
```

#### Metadata boxes

[Metadata boxes][metadata-boxes] were added to Vagrant in 1.5 and power Vagrant
Cloud. You can host your own metadata and bypass Vagrant Cloud entirely.

Essentially, you point your `box_url` at a [JSON metadata file][metadata-boxes]
that tells Vagrant where to find all possible versions:

```ruby
# Vagrantfile

Vagrant.configure('2') do |config|
  config.vm.box     = 'examplecorp/secrets'
  config.vm.box_url = 's3://example.com/secrets'
end
```

```json
"s3://example.com/secrets"

{
  "name": "examplecorp/secrets",
  "description": "This box contains company secrets.",
  "versions": [{
    "version": "0.1.0",
    "providers": [{
      "name": "virtualbox",
      "url": "https://s3.amazonaws.com/example.com/secrets.box",
      "checksum_type": "sha1",
      "checksum": "foo"
    }]
  }]
}
```

**Note:** box URLs in metadata JSON must use the
`s3.amazonaws.com/bucket.example.com/resource.box` URL form, or it won't get
auto-signed.

### Rules

To sum up:

* Only the `box_url` setting can use the `s3://` shorthand. URLs entered on the
  Vagrant Cloud management interface and in JSON metadata must use the full
  HTTPS URL.

* The full HTTPS URL must be of the form
  `https://s3.amazonaws.com/bucket.example.com/resource.box`, or it won't be
  signed properly.

* Metadata box files must *not* end in `.box`.

* Actual box files *must* end in `.box`.

### Auto-install

The beauty of Vagrant is the magic of "`vagrant up` and done." Making your users
install a plugin is lame.

But wait! Just stick some shell in your Vagrantfile:

```ruby
%x(vagrant plugin install vagrant-s3auth) unless Vagrant.has_plugin?('vagrant-s3auth')
```


[aws-signed]: http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth
[metadata-boxes]: http://docs.vagrantup.com/v2/boxes/format.html
[vagrant]: http://vagrantup.com
[vagrant-cloud]: http://vagrantcloud.com
