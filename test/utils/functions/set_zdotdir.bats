#!/usr/bin/env bats
setup() {
  ZSHENV=$(mktemp)
}

teardown() {
  rm $ZSHENV
}

set_zdotdir() {
  . $HOME/.config/zdotdir/utils/functions/set_zdotdir $1 $2
}

debug() {
  status="$1"
  output="$2"
  if [[ ! "${status}" -eq "0" ]]; then
    echo "status: ${status}"
    echo "output: ${output}"
  fi
}

@test 'Print set_zdotdir usage' {
  alias >&3
  run set_zdotdir

  [[ "${status}" == 1 ]]
  [[ "${output}" =~ "Updates ZDOTDIR environment variable from .zshenv" ]]
}

@test 'Add ZDOTDIR line to a file' {

  run set_zdotdir "/my/path" $ZSHENV
  FILE_CONTENT=$(cat $ZSHENV)

  [[ "${status}" == 0 ]]
  [[ $FILE_CONTENT == "ZDOTDIR=/my/path" ]]
}
