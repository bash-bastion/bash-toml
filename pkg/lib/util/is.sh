# shellcheck shell=bash

is.whitespace() {
	if [[ "$1" == @($'\u0009'|$'\u0020') ]]; then
		return 0
	else
		return 1
	fi
}

is.newline() {
	if [[ "$1" == @($'\u000A'|$'\u0D0A') ]]; then
		return 0
	else
		return 1
	fi
}

is.table() {
	if [[ "$1" == '[' ]]; then
		return 0
	else
		return 1
	fi
}

is.double_quote() {
	if [[ "$1" == '"' ]]; then
		return 0
	else
		return 1
	fi
}

is.single_quote() {
	if [[ "$1" == "'" ]]; then
		return 0
	else
		return 1
	fi
}

is.valid_bare_key_char() {
	if [[ "$1" == [A-Za-z0-9_-] ]]; then
		return 0
	else
		return 1
	fi
}

is.equals_sign() {
	if [[ "$1" == = ]]; then
		return 0
	else
		return 1
	fi
}

is.empty() {
	if [[ "$1" == '' ]]; then
		return 0
	else
		return 1
	fi
}
