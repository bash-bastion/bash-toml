# shellcheck shell=bash

bash_toml.debug() {
	if [ -n "${DEBUG+x}" ]; then
		printf '%s\n' "$mode ($char) at $PARSER_LINE_NUMBER:$PARSER_COLUMN_NUMBER"
	fi
}

bash_toml.die() {
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
