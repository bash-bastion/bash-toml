# shellcheck shell=bash

declare -gA BASH_TOML_ERRORS=(
	[NOT_IMPLEMENTED]='TOML feature has not been implemented'
	[UNEXPECTED_BRANCH]='This branch was not supposed to be activated. Please submit an issue'
	[KEY_ABSENT]='Key does not have a value'
	[UNEXPECTED_EOF]='Unexpected end of line'
	[UNEXPECTED_CHARACTER]='An unexpected character was encountered' # Generalization of any of the following errors
	[KEY_INVALID]='The key is not valid'
	[VALUE_INVALID]='The value could not be parsed'
	[VALUE_STRING_INVALID]='The string value could not be parsed'
)

declare -a BASH_TOKEN_HISTORY=()

# @description Appends to token history for improved error insight
bash_toml.token_history_add() {
	local str=
	printf -v str '%s' "$mode ($char) at $PARSER_LINE_NUMBER:$PARSER_COLUMN_NUMBER"

	BASH_TOKEN_HISTORY+=("$str")

	if [ -n "${DEBUG_BASH_TOML+x}" ]; then
		if [ -n "${BATS_RUN_TMPDIR+x}" ]; then
			printf '%s\n' "$str" >&3
		else
			printf '%s\n' "$str"
		fi
	fi
}

bash_toml.parse_fail() {
	local error_key="$1"
	local error_context="$2"

	if [ -z "$error_context" ]; then
		error_context="<empty>"
	fi

	local error_message="${BASH_TOML_ERRORS["$error_key"]}"

	local error_output=
	printf -v error_output 'Failed to parse toml:
  -> code: %s
  -> message: %s
  -> context: %s
  -> history:' "$error_key" "$error_message" "$error_context"

	for history_item in "${BASH_TOKEN_HISTORY[@]}"; do
		printf -v error_output '%s\n    - %s' "$error_output" "$history_item"
	done

	if [ "$TOML_MANUAL_ERROR" = yes ]; then
		TOML_ERROR="$error_output"
		return 1
	else
		printf '%s' "$error_output"
		exit 1
	fi
}
