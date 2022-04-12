# shellcheck shell=bash

btoml.is.whitespace() {
	if [[ "$1" == @($'\u0009'|$'\u0020') ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.newline() {
	if [[ "$1" == @($'\u000A'|$'\u0D0A') ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.table() {
	if [[ "$1" == \[ ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.double_quote() {
	if [[ "$1" == \" ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.single_quote() {
	if [[ "$1" == \' ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.backslash() {
	# shellcheck disable=SC1003
	if [[ "$1" == \\ ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.control_character() {
	# shellcheck disable=SC1003
	if [[ "$1" == [[:cntrl:]] ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.hex_digit() {
	# shellcheck disable=SC1003
	if [[ "$1" == [[:xdigit:]] ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.octothorp() {
	# shellcheck disable=SC1003
	if [[ "$1" == \# ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.valid_bare_key_char() {
	if [[ "$1" == [A-Za-z0-9_-] ]]; then
		return 0
	else
		return 1
	fi
}

btoml.is.equals_sign() {
	if [[ "$1" == = ]]; then
		return 0
	else
		return 1
	fi
}
