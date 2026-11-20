#!/usr/bin/env bats
# Run: mise x bats@1.11.1 -- bats test/env/functions/workday-apps.bats

setup() {
  WORKDAY_APPS_STATE_DIR=$(mktemp -d)
  export WORKDAY_APPS_STATE_DIR
  export WORKDAY_APPS_TODAY=2026-11-20
  FUNCTIONS="$BATS_TEST_DIRNAME/../../../env/functions"
}

teardown() {
  rm -rf "$WORKDAY_APPS_STATE_DIR"
}

workday_apps() {
  zsh -fc 'fpath=("$1" $fpath); autoload -Uz workday-apps; shift; workday-apps "$@"' _ "$FUNCTIONS" "$@"
}

paused() {
  cat "$WORKDAY_APPS_STATE_DIR/paused-dates"
}

@test 'pause a single date' {
  run workday_apps pause 2026-12-01
  [[ $status == 0 ]]
  [[ $output == "paused Tue 2026-12-01" ]]
  [[ $(paused) == "2026-12-01" ]]
}

@test 'pause a range across a year end' {
  run workday_apps pause 2026-12-30..2027-01-02
  [[ $status == 0 ]]
  [[ $(paused) == $'2026-12-30\n2026-12-31\n2027-01-01\n2027-01-02' ]]
}

@test 'pause merges with existing dates, keeps them sorted and unique' {
  workday_apps pause 2026-12-05
  run workday_apps pause 2026-12-01 2026-12-05
  [[ $status == 0 ]]
  [[ $output == "paused Tue 2026-12-01" ]]
  [[ $(paused) == $'2026-12-01\n2026-12-05' ]]
}

@test 'pause skips past dates and prunes old ones' {
  printf '2026-11-01\n2026-12-01\n' >"$WORKDAY_APPS_STATE_DIR/paused-dates"
  run workday_apps pause 2026-11-19 2026-11-20
  [[ $status == 0 ]]
  [[ $output =~ "skipped Thu 2026-11-19: in the past" ]]
  [[ $(paused) == $'2026-11-20\n2026-12-01' ]]
}

@test 'reject a date that does not exist' {
  run workday_apps pause 2026-02-30
  [[ $status == 1 ]]
  [[ $output =~ "not a date or range: 2026-02-30" ]]
  [[ ! -e "$WORKDAY_APPS_STATE_DIR/paused-dates" ]]
}

@test 'reject a malformed date and a reversed range' {
  run workday_apps pause 2026-12-1
  [[ $status == 1 ]]
  run workday_apps pause 2026-12-10..2026-12-01
  [[ $status == 1 ]]
  [[ $output =~ "range ends before it starts" ]]
}

@test 'reject a range longer than a year' {
  run workday_apps pause 2026-12-01..2028-01-01
  [[ $status == 1 ]]
  [[ $output =~ "range longer than a year" ]]
}

@test 'resume removes dates from a range and reports misses' {
  workday_apps pause 2026-12-01..2026-12-03
  run workday_apps resume 2026-12-02
  [[ $output == "resumed Wed 2026-12-02" ]]
  [[ $(paused) == $'2026-12-01\n2026-12-03' ]]
  run workday_apps resume 2026-12-25
  [[ $output == "none of those dates were paused" ]]
}

@test 'status shows today, last runs and upcoming dates' {
  workday_apps pause 2026-11-20 2026-12-01
  echo "2026-11-20 07:00 started Slack, Microsoft Teams, Roar" >"$WORKDAY_APPS_STATE_DIR/last-open"
  run workday_apps status
  [[ $status == 0 ]]
  [[ ${lines[0]} == "today Fri 2026-11-20: paused" ]]
  [[ ${lines[1]} == "  open run: done 07:00 started Slack, Microsoft Teams, Roar" ]]
  [[ ${lines[2]} == "  close run: not yet" ]]
  [[ ${lines[4]} == "  Fri 2026-11-20" ]]
  [[ ${lines[5]} == "  Tue 2026-12-01" ]]
}

@test 'no arguments without a terminal prints usage' {
  run workday_apps
  [[ $status == 1 ]]
  [[ $output =~ "usage: workday-apps" ]]
}

@test 'unknown action prints usage' {
  run workday_apps frobnicate
  [[ $status == 1 ]]
  [[ $output =~ "usage: workday-apps" ]]
}
