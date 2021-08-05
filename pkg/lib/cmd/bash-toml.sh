# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob globasciiranges

source "$BASH_TOML_LIB_DIR/util/is.sh"
source "$BASH_TOML_LIB_DIR/util/util.sh"
source "$BASH_TOML_LIB_DIR/util/error.sh"

bash-toml() {
	declare char=
	declare mode='MODE_DEFAULT'
	declare -i PARSER_LINE_NUMBER=0
	declare -i PARSER_COLUMN_NUMBER=0

	while IFS= read -rn 1 char; do
		if is.newline "$char"; then
			PARSER_LINE_NUMBER+=1
			PARSER_COLUMN_NUMBER=0
		else
			PARSER_COLUMN_NUMBER+=1
		fi

		debug

		case "$mode" in
		MODE_DEFAULT)
			if is.whitespace "$char"; then
				:
			elif is.newline "$char"; then
				:
			elif is.table "$char"; then
				die "Tables are not supported"
			elif is.double_quote "$char"; then
				die "Quoted keys are not supported"
			elif is.valid_bare_key_char "$char"; then
				create_key_token "$char"
				mode="DURING_BARE_KEY"
			else
				die "Character '$char' is not valid in this context"
			fi
			;;
		BEFORE_SOME_VALUE)
			if is.whitespace "$char"; then
				:
			elif is.newline "$char"; then
				# TODO: not being fired?
				die "Key name found without value 2"
			elif is.double_quote "$char"; then
				die "Double quote values are not supported"
				mode='DURING_VALUE_DOUBLE_QUOTE'
				create_key_value
			elif is.single_quote "$char"; then
				mode='DURING_VALUE_SINGLE_QUOTE'
				create_key_value
				# die "Single quote values are not supported"
			elif is.empty "$char"; then
				die "Expected value"
			else
				die "Datetime, Boolean, Float, Integer, Array, Inline Table, etc. etc. Are not supported"
			fi
			;;
		AFTER_ANY_VALUE)
			if is.whitespace "$char"; then
				:
			elif is.newline "$char"; then
				mode='MODE_DEFAULT'
			elif is.empty "$char"; then
				mode='MODE_DEFAULT'
			else
				die "Newline expected"
			fi
			;;
		# directly after the `"`
		DURING_VALUE_DOUBLE_QUOTE)

			# append_key_value "$char"
			;;
		# directly after the `'`
		DURING_VALUE_SINGLE_QUOTE)
			if is.single_quote "$char"; then
				mode='AFTER_ANY_VALUE'
			elif is.newline "$char"; then
				die "Newlines are not valid in single quote"
			else
				append_key_value "$char"
			fi
			;;
		DURING_BARE_KEY)
			if is.whitespace "$char"; then
				mode="BEFORE_KEY_EQUALS"
			elif is.newline "$char"; then
				die "Key name found without value"
			elif is.valid_bare_key_char "$char"; then
				append_key_token "$char"
			elif is.empty "$char"; then
				die "Cannot reach end of file right now, have not finished parsing key"
			else
				die "Character '$char' is not valid in this context"
			fi
			;;
		BEFORE_KEY_EQUALS)
			if is.equals_sign "$char"; then
				mode="BEFORE_SOME_VALUE"
			elif is.empty "$char"; then
				die "No equals sign found. End of file reached"
			else
				die "Expected equals sign; not '$char'"
			fi
		esac

	done

	case "$mode" in
	MODE_DEFAULT)
		# i.g. ``
		:
		;;
	BEFORE_SOME_VALUE)
		die "Key name found without value theta"
		;;
	DURING_BARE_KEY)
		#  i.g. `keyName`
		die "Key name found without value"
		;;
	BEFORE_KEY_EQUALS)
		;;
	esac

	TOML["$KEY_TOKEN"]="$KEY_VALUE"
}
