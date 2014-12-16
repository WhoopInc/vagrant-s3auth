# Contributing

We love contributions! Pull request away.

## Hacking

You'll need Ruby and Bundler, of course. Then, check out the code and install
the gems:

```bash
$ git clone git@github.com:WhoopInc/vagrant-s3auth.git
$ cd vagrant-s3auth
$ bundle
```

Hack away! When you're ready to test, either [run the test suite](TESTING.md) or
run Vagrant manually *using the configured Bundler environment*:

```bash
$ VAGRANT_LOG=debug bundle exec vagrant box add S3_URL
```

If you forget the `bundle exec`, you'll use system Vagrant—not the Vagrant that
has your plugin changes installed!

## Guidelines

We do ask that all contributions pass the linter and test suite. Travis will
automatically run these against your contribution once you submit the pull
request, but you can also run them locally as you go!

### Linting

```bash
$ rake lint
```

### Testing

See [TESTING](TESTING.md).
