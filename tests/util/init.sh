# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

load './util/test_util.sh'
# TODO: remove stderr shell redirection
load "$(bpm package-path 'ztombol/bats-support' 2>/dev/null)/load.bash"
load "$(bpm package-path 'ztombol/bats-assert' 2>/dev/null)/load.bash"

export LANG="C"
export LANGUAGE="C"
export LC_ALL="C"

ROOT_DIR="$(realpath "${BASH_SOURCE[0]}")"
ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"

export PATH="$ROOT_DIR/pkg/bin:$PATH"
for f in "$ROOT_DIR"/pkg/lib/{commands,util}/?*.sh; do
	# shellcheck disable=SC1090
	source "$f"
done

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
