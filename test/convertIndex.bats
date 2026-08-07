#!/usr/bin/env bats

# Load bats-assert and bats-support. Override BATS_ASSERT_LIB_PATH if your
# npm global node_modules lives elsewhere.
BATS_ASSERT_LIB_PATH="${BATS_ASSERT_LIB_PATH:-$HOME/.pixi/envs/nodejs/lib/node_modules}"
load "$BATS_ASSERT_LIB_PATH/bats-support/load.bash"
load "$BATS_ASSERT_LIB_PATH/bats-assert/load.bash"

CI_FIXTURE="$BATS_TEST_DIRNAME/convertIndex.md"
CI_FILTER="$BATS_TEST_DIRNAME/../filters/convertIndex.lua"
CI_EXPECTED="$BATS_TEST_DIRNAME/expected"

# Compare convertIndex.lua output for a text format against a golden file in
# test/expected/convertIndex-<name>. Regenerate with:
#   pandoc test/convertIndex.md -L filters/convertIndex.lua -t <name> \
#     > test/expected/convertIndex-<name>
ci_check() {
  local name="$1"
  run pandoc "$CI_FIXTURE" -L "$CI_FILTER" -t "$name"
  assert_success
  assert_output "$(cat "$CI_EXPECTED/convertIndex-$name")"
}

# Extract XML from an odt (content.xml) or docx (word/document.xml) and
# run it as the `run` command, so the caller can assert on the XML text.
ci_xml() {
  local ext="$1"     # 'odt' or 'docx'
  local member="$2"  # xml member inside the archive
  local out="$BATS_TEST_TMPDIR/convertIndex.$ext"
  run bash -c "pandoc \"$CI_FIXTURE\" -L \"$CI_FILTER\" -t $ext -o \"$out\" \
    && python3 -c 'import zipfile,sys; sys.stdout.write(zipfile.ZipFile(sys.argv[1]).read(sys.argv[2]).decode())' \"$out\" \"$member\""
  assert_success
}

@test "convertIndex.lua latex output" {
  ci_check latex
}

@test "convertIndex.lua typst output" {
  ci_check typst
}

@test "convertIndex.lua fallback (html) output" {
  ci_check html
}

@test "convertIndex.lua odt output (native XML)" {
  ci_xml odt content.xml
  assert_output --partial '<text:alphabetical-index-mark text:string-value="BlockAlpha"/>'
  assert_output --partial '<text:alphabetical-index-mark text:key1="Ancestor" text:key2="Parent" text:string-value="Item"/>'
  assert_output --partial '<text:alphabetical-index-mark text:main-entry="true" text:string-value="Gamma"/>'
  assert_output --partial '<text:alphabetical-index-mark-start text:id="IMarkX1" />'
  assert_output --partial '<text:alphabetical-index-mark-end text:id="IMarkX1"/>'
}

@test "convertIndex.lua docx output (native XML)" {
  ci_xml docx word/document.xml
  assert_output --partial 'XE "'
  assert_output --partial '<w:instrText>BlockAlpha</w:instrText>'
  assert_output --partial '<w:instrText>Ancestor:Parent:Item</w:instrText>'
  assert_output --partial '<w:instrText>Delta, see—Epsilon</w:instrText>'
  assert_output --partial '<w:t>here</w:t>'
}

@test "convertIndex.lua passes through a document without index" {
  run bash -c "printf 'hello\n\nworld\n' | pandoc -L \"$CI_FILTER\" -t plain"
  assert_success
  assert_output "$(cat <<'EOF'
hello

world
EOF
  )"
}

