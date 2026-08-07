#!/usr/bin/env bats
# see https://bats-core.readthedocs.io/en/stable/

# Load bats-assert and bats-support. Override BATS_ASSERT_LIB_PATH if your
# npm global node_modules lives elsewhere.
BATS_ASSERT_LIB_PATH="${BATS_ASSERT_LIB_PATH:-$HOME/.pixi/envs/nodejs/lib/node_modules}"
load "$BATS_ASSERT_LIB_PATH/bats-support/load.bash"
load "$BATS_ASSERT_LIB_PATH/bats-assert/load.bash"

ALERTS_FIXTURE="$BATS_TEST_DIRNAME/alerts.md"
ALERTS_FILTER="$BATS_TEST_DIRNAME/../filters/alerts.lua"
ALERTS_EXPECTED="$BATS_TEST_DIRNAME/expected"

# Test that text-format output of filters/alerts.lua matches the stored
# golden files in test/expected/alerts-<format>. Regenerate with:
#   pandoc test/alerts.md -L filters/alerts.lua -t <fmt> > test/expected/alerts-<fmt>

@test "alerts.lua typst output" {
  run pandoc "$ALERTS_FIXTURE" -L "$ALERTS_FILTER" -t typst
  assert_success
  assert_output "$(cat "$ALERTS_EXPECTED/alerts-typst")"
}

@test "alerts.lua plain output" {
  run pandoc "$ALERTS_FIXTURE" -L "$ALERTS_FILTER" -t plain
  assert_success
  assert_output "$(cat "$ALERTS_EXPECTED/alerts-plain")"
}

@test "alerts.lua latex output" {
  run pandoc "$ALERTS_FIXTURE" -L "$ALERTS_FILTER" -t latex
  assert_success
  assert_output "$(cat "$ALERTS_EXPECTED/alerts-latex")"
}

@test "alerts.lua html output" {
  run pandoc "$ALERTS_FIXTURE" -L "$ALERTS_FILTER" -t html
  assert_success
  assert_output "$(cat "$ALERTS_EXPECTED/alerts-html")"
}

@test "alerts.lua gfm output" {
  run pandoc "$ALERTS_FIXTURE" -L "$ALERTS_FILTER" -t gfm
  assert_success
  assert_output "$(cat "$ALERTS_EXPECTED/alerts-gfm")"
}

@test "alerts.lua latex standalone injects tcolorbox preamble" {
  run pandoc "$ALERTS_FIXTURE" -L "$ALERTS_FILTER" -s -t latex
  assert_success
  assert_output --partial '\usepackage{tcolorbox}'
  assert_output --partial '\newtcolorbox{alertnote}'
  assert_output --partial '\newtcolorbox{alertcaution}'
}

@test "alerts.lua passes through a document without alerts" {
  run bash -c "printf 'hello\n\nworld\n' | pandoc -L \"$ALERTS_FILTER\" -t plain"
  assert_success
  assert_output "$(cat <<'EOF'
hello

world
EOF
  )"
}
