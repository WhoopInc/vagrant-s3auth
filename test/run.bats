#!/usr/bin/env bats

missing_vars=()

require_var() {
  [[ "${!1}" ]] || missing_vars+=("$1")
}

require_var AWS_ACCESS_KEY_ID
require_var AWS_SECRET_ACCESS_KEY
require_var ATLAS_TOKEN
require_var ATLAS_USERNAME
require_var VAGRANT_S3AUTH_BUCKET
require_var VAGRANT_S3AUTH_BOX_BASE
require_var VAGRANT_S3AUTH_ATLAS_BOX_NAME
require_var VAGRANT_S3AUTH_REGION_NONSTANDARD

if [[ ${#missing_vars[*]} -gt 0 ]]; then
  echo "Missing required environment variables:"
  printf '    %s\n' "${missing_vars[@]}"
  exit 1
fi

teardown() {
  bundle exec vagrant box remove "$VAGRANT_S3AUTH_BOX_BASE" > /dev/null 2>&1 || true
  bundle exec vagrant box remove "public-$VAGRANT_S3AUTH_BOX_BASE" > /dev/null 2>&1 || true
  bundle exec vagrant box remove "vagrant-s3auth-mfa/$VAGRANT_S3AUTH_BOX_BASE" > /dev/null 2>&1 || true
  bundle exec vagrant box remove "vagrant-s3auth-mfa/public-$VAGRANT_S3AUTH_BOX_BASE" > /dev/null 2>&1 || true
  bundle exec vagrant box remove "$ATLAS_USERNAME/$VAGRANT_S3AUTH_ATLAS_BOX_NAME" > /dev/null 2>&1 || true
}

@test "vagrant cloud" {
  bundle exec vagrant box add "$ATLAS_USERNAME/$VAGRANT_S3AUTH_ATLAS_BOX_NAME"
}

@test "simple box with full path standard url" {
  bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3.amazonaws.com/us-east-1.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "public simple box with full path standard url without credentials" {
  AWS_ACCESS_KEY_ID= \
    bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3.amazonaws.com/us-east-1.$VAGRANT_S3AUTH_BUCKET/public-$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "simple box with full host standard url" {
  bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "https://us-east-1.$VAGRANT_S3AUTH_BUCKET.s3.amazonaws.com/$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "simple box with shorthand standard url" {
  bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "s3://us-east-1.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "simple box with full path nonstandard url" {
  bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3-$VAGRANT_S3AUTH_REGION_NONSTANDARD.amazonaws.com/$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "public simple box with full path nonstandard url without credentials" {
  AWS_ACCESS_KEY_ID= \
    bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3-$VAGRANT_S3AUTH_REGION_NONSTANDARD.amazonaws.com/$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET/public-$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "simple box with full host nonstandard url" {
  bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "https://$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET.s3-$VAGRANT_S3AUTH_REGION_NONSTANDARD.amazonaws.com/$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "simple box with shorthand nonstandard url" {
  bundle exec vagrant box add \
    --name "$VAGRANT_S3AUTH_BOX_BASE" \
    "s3://$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE.box"
}

@test "metadata box with full path standard url" {
  bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3.amazonaws.com/us-east-1.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE"
}

@test "public metadata box with full path standard url without credentials" {
  AWS_ACCESS_KEY_ID= \
    bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/public-$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3.amazonaws.com/us-east-1.$VAGRANT_S3AUTH_BUCKET/public-$VAGRANT_S3AUTH_BOX_BASE"
}

@test "metadata box with full host standard url" {
  bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/$VAGRANT_S3AUTH_BOX_BASE" \
    "https://us-east-1.$VAGRANT_S3AUTH_BUCKET.s3.amazonaws.com/$VAGRANT_S3AUTH_BOX_BASE"
}

@test "metadata box with shorthand standard url" {
  bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/$VAGRANT_S3AUTH_BOX_BASE" \
    "s3://us-east-1.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE"
}

@test "metadata box with full path nonstandard url" {
  bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3-$VAGRANT_S3AUTH_REGION_NONSTANDARD.amazonaws.com/$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE"
}

@test "public metadata box with full path nonstandard url without credentials" {
  AWS_ACCESS_KEY_ID= \
    bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/public-$VAGRANT_S3AUTH_BOX_BASE" \
    "https://s3-$VAGRANT_S3AUTH_REGION_NONSTANDARD.amazonaws.com/$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET/public-$VAGRANT_S3AUTH_BOX_BASE"
}


@test "metadata box with full host nonstandard url" {
  bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/$VAGRANT_S3AUTH_BOX_BASE" \
    "https://$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET.s3-$VAGRANT_S3AUTH_REGION_NONSTANDARD.amazonaws.com/$VAGRANT_S3AUTH_BOX_BASE"
}

@test "metadata box with shorthand nonstandard url" {
  bundle exec vagrant box add \
    --name "vagrant-s3auth-mfa/$VAGRANT_S3AUTH_BOX_BASE" \
    "s3://$VAGRANT_S3AUTH_REGION_NONSTANDARD.$VAGRANT_S3AUTH_BUCKET/$VAGRANT_S3AUTH_BOX_BASE"
}

@test "garbage shorthand url" {
  run bundle exec vagrant box add --name "$VAGRANT_S3AUTH_BOX_BASE" s3://smoogedydoop
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Malformed shorthand S3 box URL"* ]]
}

@test "garbage full url" {
  run bundle exec vagrant box add --name "$VAGRANT_S3AUTH_BOX_BASE" https://smoogedydoop
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"error occurred while downloading the remote file"* ]]
}
