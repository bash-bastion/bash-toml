# shellcheck shell=bash

test_util.object_has_key() {
	local key="$1"

	if [ -z "${TOML["$key"]+abc}" ]; then
		:
	fi
}

test_util.object_has_key_and_value() {
	local key="$1"
	local value="$2"

	assert [ "${TOML["$key"]}" = "$value" ]
}
