# shellcheck shell=bash

# TODO
set -ETeo pipefail
shopt -s nullglob extglob globasciiranges

eval "$(basalt-package-init)"; basalt.package-init
basalt.package-load

load './util/test_util.sh'

# TODO: move to some 'preexec?'
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export DEBUG=
export TEST_MODE=

setup() {
	unset TOML
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
