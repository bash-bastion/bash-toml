# shellcheck shell=bash

basalt_load() {
	for f in "$BASALT_PACKAGE_PATH"/pkg/lib/{commands,source,util}/?*.sh; do
		source "$f"
	done; unset f
}
