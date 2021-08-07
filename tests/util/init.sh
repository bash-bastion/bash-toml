# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob globasciiranges

load './util/test_util.sh'

source bpm-load
bpm-load 'ztombol/bats-support'
bpm-load 'ztombol/bats-assert'

export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export DEBUG=
export TEST_MODE=

ROOT_DIR="$(realpath "${BASH_SOURCE[0]}")"
ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"; ROOT_DIR="${ROOT_DIR%/*}"

export PATH="$ROOT_DIR/pkg/bin:$PATH"
for f in "$ROOT_DIR"/pkg/lib/{commands,util}/?*.sh; do
	# shellcheck disable=SC1090
	source "$f"
done

setup() {
	unset TOML
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
