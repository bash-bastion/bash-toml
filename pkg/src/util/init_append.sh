# shellcheck shell=bash

btoml.init_key_string() {
	BASH_TOML_KEY_STRING="$1"
}

btoml.append_key_string() {
	BASH_TOML_KEY_STRING+="$1"
}

btoml.init_value_string() {
	BASH_TOML_KEY_VALUE_STRING=
}

btoml.append_value_string() {
	BASH_TOML_KEY_VALUE_STRING+="$1"
}
