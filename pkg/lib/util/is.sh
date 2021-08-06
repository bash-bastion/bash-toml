# shellcheck shell=bash

bash_toml.is.whitespace() {
	if [[ "$1" == @($'\u0009'|$'\u0020') ]]; then
		return 0
	else
		return 1
	fi
}

bash_toml.is.newline() {
	if [[ "$1" == @($'\u000A'|$'\u0D0A') ]]; then
		return 0
	else
		return 1
	fi
}

bash_toml.is.table() {
	if [[ "$1" == '[' ]]; then
		return 0
	else
		return 1
	fi
}

bash_toml.is.double_quote() {
	if [[ "$1" == '"' ]]; then
		return 0
	else
		return 1
	fi
}

bash_toml.is.single_quote() {
	if [[ "$1" == "'" ]]; then
		return 0
	else
		return 1
	fi
}

bash_toml.is.valid_bare_key_char() {
	if [[ "$1" == [A-Za-z0-9_-] ]]; then
		return 0
	else
		return 1
	fi
}

bash_toml.is.equals_sign() {
	if [[ "$1" == = ]]; then
		return 0
	else
		return 1
	fi
}

bash_toml.is.empty() {
	if [[ "$1" == '' ]]; then
		return 0
	else
		return 1
	fi
}
