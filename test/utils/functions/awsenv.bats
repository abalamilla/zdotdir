#!/usr/bin/env bats

setup() {
  AWS_CONFIG_FILE=$(mktemp)
  OFFICE_PROFILE=$(mktemp)
}

teardown() {
  rm $AWS_CONFIG_FILE
  rm $OFFICE_PROFILE
}

aws() {
  method=$2

  if [[ $method == "set" ]]; then
    echo "aws config set $@ called"
    return
  fi

  $(which aws) $@
}

awsenv() {
  . $HOME/.config/zdotdir/env/functions/awsenv $@
}

@test 'Print awsenv usage when no arguments are passed' {
  run awsenv

  [[ "${status}" == 1 ]]
  [[ "${output}" =~ "usage: awsenv [--profile <profile>] [--region <region>]\n" ]]
}

@test 'Print awsenv usage when invalid arguments are passed' {
  run awsenv --invalid-argument

  [[ "${status}" == 1 ]]
  [[ "${output}" =~ "usage: awsenv [--profile <profile>] [--region <region>]\n" ]]
}

@test 'Print awsenv usage when theres no active profile and region is provided' {
  unset AWS_PROFILE
  run awsenv --region my-region

  [[ "${status}" == 1 ]]
  [[ "${output}" =~ "profile not set" ]]
}

@test 'Print awsenv usage when theres no active profile and region is not provided' {
  unset AWS_PROFILE
  profile=my-profile
  run awsenv --profile $profile

  [[ "${status}" == 1 ]]
  [[ "${output}" =~ "profile $profile does not exist" ]]
}

@test 'Should fail when theres no aws credentials in the clipboard' {
  echo "no credentials" | pbcopy
  run awsenv --profile my-profile --region my-region

  [[ "${status}" == 1 ]]
  [[ "${output}" =~ "aws credentials not found in clipboard" ]]
}

@test 'Should succeed when aws credentials are in the clipboard and profile and region are provided' {
  echo "AWS_access_key_id=my-access-key-id" | pbcopy
  run awsenv --profile my-profile --region my-region

  echo this is the $AWS_CONFIG_FILE $(cat $AWS_CONFIG_FILE) >&3
  echo this another $AWS_SHARED_CREDENTIALS_FILE $(cat $AWS_SHARED_CREDENTIALS_FILE) >&3

  cat $AWS_CONFIG_FILE >&3
  cat $AWS_SHARED_CREDENTIALS_FILE >&3
  cat $OFFICE_PROFILE >&3

  [[ "${status}" == 0 ]]
  [[ "${output}" =~ "aws default profile set to my-profile. Reload other shells to apply changes." ]]
}

