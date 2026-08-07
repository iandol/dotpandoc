#!/usr/bin/env bats

# Load bats-assert and bats-support. Override BATS_ASSERT_LIB_PATH if your
# npm global node_modules lives elsewhere.
BATS_ASSERT_LIB_PATH="${BATS_ASSERT_LIB_PATH:-$HOME/.pixi/envs/nodejs/lib/node_modules}"
load "$BATS_ASSERT_LIB_PATH/bats-support/load.bash"
load "$BATS_ASSERT_LIB_PATH/bats-assert/load.bash"

QV_FIXTURE="$BATS_TEST_DIRNAME/querverweis.md"
QV_FILTER="$BATS_TEST_DIRNAME/../filters/querverweis.lua"
QV_EXPECTED="$BATS_TEST_DIRNAME/expected"

# Compare querverweis.lua output for a given set of `-M` metadata options
# against a golden file in test/expected/querverweis-<name>. Regenerate with:
#   pandoc test/querverweis.md -L filters/querverweis.lua [ -M querverweis.... ] \
#     > test/expected/querverweis-<name>
qv_check() {
  local name="$1"; shift
  run pandoc "$QV_FIXTURE" -L "$QV_FILTER" -t markdown "$@"
  assert_success
  assert_output "$(cat "$QV_EXPECTED/querverweis-$name")"
}

@test "querverweis.lua default (no metadata)" {
  qv_check default
}

@test "querverweis.lua labels via -M (caption labels)" {
  qv_check labels -M querverweis.labels=true
}

@test "querverweis.lua link-labels via -M (default names)" {
  qv_check linklabels -M querverweis.link-labels=true
}

@test "querverweis.lua link-names via -M (custom link names)" {
  qv_check linknames \
    -M querverweis.link-labels=true \
    -M querverweis.link-names.figure=Fig. \
    -M querverweis.link-names.table=Table
}

@test "querverweis.lua numbering via -M (1.1 per section)" {
  qv_check numbering -M querverweis.numbering=1.1
}

@test "querverweis.lua passes through a document without index" {
  run bash -c "printf 'hello\n\nworld\n' | pandoc -L \"$QV_FILTER\" -t plain"
  assert_success
  assert_output "$(cat <<'EOF'
hello

world
EOF
  )"
}


