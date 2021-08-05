# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

export LANG="C"
export LANGUAGE="C"
export LC_ALL="C"

test_util.get_root

export BASH_TOML_ROOT="$REPLY"

export PATH="$BASH_TOML_ROOT/pkg/bin:$PATH"
for f in "$BASH_TOML_ROOT"/pkg/lib/{commands,util}/?*.sh; do
	source "$f"
done

# setup() {
# 	mkdir -p "$BPM_TEST_DIR" "$BPM_CWD" "$BPM_ORIGIN_DIR"
# 	cd "$BPM_CWD"
# }

# teardown() {
# 	rm -rf "$BPM_TEST_DIR"
# }
