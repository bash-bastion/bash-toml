# shellcheck shell=bash

declare -gA errors=(
	[NOT_IMPLEMENTED]='The feature has not been implemented'
	[UNEXPECTED_BRANCH]='Unaccounted value'
	[INCOMPLETE_KEY]='The key could not completely be parsed'
	[INVALID_KEY]='The key is not valid'
	[INCOMPLETE_VALUE_ANY]='The key did not have a proper value'
)

bash_toml.debug() {
	if [ -n "${DEBUG+x}" ]; then
		printf '%s\n' "$mode ($char) at $PARSER_LINE_NUMBER:$PARSER_COLUMN_NUMBER"
	fi
}

bash_toml.die() {
	bash_toml.debug >&3
	cat <<-EOF

		char: $char
		mode: $mode
	EOF

	if [ "$TOML_MANUAL_ERROR" = yes ]; then
		TOML_ERROR="$1"
		return 1
	else
		if [[ -n "${NO_COLOR+x}" || $TERM = dumb ]]; then
			printf '%s\n' "Fatal: $1"
		else
			printf '\033[0;31m%s\033[0m\n' "Fatal: $1"
		fi
		exit 1
	fi
}



bash_toml.parse_fail() {
	bash_toml.debug >&3
	cat <<-EOF

		char: $char
		mode: $mode
	EOF

	local error_key="$1"
	local error_context="$2"

	local error_message="${errors[$error_key]}"

	printf -v error_output 'Failed to parse toml:\n  -> code: %s\n  -> message: %s\n  -> context: %s' "$error_key" "$error_message" "$error_context"

	if [ "$TOML_MANUAL_ERROR" = yes ]; then
		TOML_ERROR="$error_output"
		return 1
	else
		printf '%s' "$error_output"
		# if [[ -n "${NO_COLOR+x}" || $TERM = dumb ]]; then
		# 	printf '%s\n' "Fatal: $1"
		# else
		# 	printf '\033[0;31m%s\033[0m\n' "Fatal: $1"
		# fi
		exit 1
	fi



}
