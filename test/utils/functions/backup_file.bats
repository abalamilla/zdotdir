#!/usr/bin/env bats
setup() {
  FAKE_FILE=$(mktemp)
  FAKE_DIR=$(mktemp -d)
}

teardown() {
  rm -f "$FAKE_FILE"
  rm -Rf "$FAKE_DIR"
}

backup_file() {
  . "$HOME/zdotdir/utils/functions/backup_file" "$@"
}

print_message() {
  echo "$1"
}

@test 'Print backup_file usage' {
  run backup_file

  [[ "${status}" == 1 ]]
  [[ "${output}" =~ "backup_file file_path destination_path [new_file_name]" ]]
}

@test 'Backup file not found' {
  run backup_file "/path/to/fake/file" "/path/to/destination/dir"

  [[ "${status}" == 1 ]]
  [[ "${output}" == "The file /path/to/fake/file do not exists." ]]
}

@test 'User without write permission on dest path' {
  run backup_file "$FAKE_FILE" "/"

  [[ "${status}" == 1 ]]
  [[ "${output}" == "Current user do not have write permissions over /." ]]
}

@test 'Backup a file' {
  run backup_file "$FAKE_FILE" "$FAKE_DIR" "my_backup.bkp"

  [[ "${status}" == 0 ]]
  [[ -f "$FAKE_DIR/my_backup.bkp" ]]
}
