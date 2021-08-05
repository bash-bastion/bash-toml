# shellcheck shell=bash

debug() {
	if [[ -v DEBUG ]]; then
		echo "$mode: $char"
	fi
}

debug_group() {
	printf '%s\n' "KEY_TOKEN: '$KEY_TOKEN'"
	printf '%s\n' "KEY_VALUE: '$KEY_VALUE'"
	printf '%s\n' "PARSER_LINE_NUMBER: '$PARSER_LINE_NUMBER'"
	printf '%s\n' "PARSER_COLUMN_NUMBER: '$PARSER_COLUMN_NUMBER'"
}

d() {
	if [[ -v DEBUG ]]; then
		echo "$1"
	fi
}

die() {
	printf '\033[0;31m%s\n\033[0m' "Fatal: $1"
	echo --- DEBUG INFO ---
	debug
	debug_group
	exit 1
}

create_key_token() {
	KEY_TOKEN="$1"
}

append_key_token() {
	KEY_TOKEN+="$1"
}

create_key_value() {
	KEY_VALUE=
}

append_key_value() {
	KEY_VALUE+="$1"
}
