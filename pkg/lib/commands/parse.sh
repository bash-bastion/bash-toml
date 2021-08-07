# shellcheck shell=bash

bash_toml.do_parse() {
	TOML_ERROR=
	TOML_MANUAL_ERROR='no'

	declare char=
	declare mode='MODE_DEFAULT'
	declare -i PARSER_LINE_NUMBER=1
	declare -i PARSER_COLUMN_NUMBER=0

	while IFS= read -rn 1 char; do
		if bash_toml.is.newline "$char"; then
			PARSER_COLUMN_NUMBER=0
			PARSER_LINE_NUMBER+=1
		else
			PARSER_COLUMN_NUMBER+=1
		fi

		bash_toml.token_history_add

		case "$mode" in
		# State in which parser starts, and before any given TOML construct
		MODE_DEFAULT)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.newline "$char"; then
				:
			elif bash_toml.is.table "$char"; then
				bash_toml.parse_fail 'NOT_IMPLEMENTED' "Tables are not supported"
				return 1
			elif bash_toml.is.double_quote "$char"; then
				bash_toml.parse_fail 'NOT_IMPLEMENTED' "Quoted keys are not supported"
				return 1
			elif bash_toml.is.valid_bare_key_char "$char"; then
				bash_toml.init_key_string "$char"
				mode="MODE_BAREKEY_DURING_KEY"
			else
				# If after only gobbling up whitespace, and there is nothign left,
				# we are done
				return 0
			fi
			;;
		MODE_ANY_BEFORE_VALUE)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.newline "$char"; then
				# TODO: not being fired?
				bash_toml.parse_fail 'KEY_ABSENT' "Key name found without value 2"
				return 1
			elif bash_toml.is.double_quote "$char"; then
				bash_toml.parse_fail 'NOT_IMPLEMENTED' "Double quote values are not supported"
				return 1
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
				bash_toml.init_value_string
			elif bash_toml.is.single_quote "$char"; then
				mode='MODE_SINGLEQUOTE_DURING_VALUE'
				bash_toml.init_value_string
			elif bash_toml.is.empty "$char"; then
				bash_toml.parse_fail 'VALUE_STRING_INVALID'
				return 1
			else
				bash_toml.parse_fail 'NOT_IMPLEMENTED' "Datetime, Boolean, Float, Integer, Array, Inline Table, etc. etc. Are not supported"
				return 1
			fi
			;;
		MODE_BAREKEY_DURING_KEY)
			if bash_toml.is.whitespace "$char"; then
				mode="MODE_EQUALS_BEFORE"
			elif bash_toml.is.equals_sign "$char"; then
				mode='MODE_ANY_BEFORE_VALUE'
			elif bash_toml.is.newline "$char"; then
				bash_toml.parse_fail 'KEY_INVALID' "Key name found without value"
				return 1
			elif bash_toml.is.valid_bare_key_char "$char"; then
				bash_toml.append_key_string "$char"
			elif bash_toml.is.empty "$char"; then
				bash_toml.parse_fail 'KEY_INVALID'
				return 1
			else
				bash_toml.parse_fail 'UNEXPECTED_CHARACTER' "Char '$char' is not valid in toml bare keys"
				return 1
			fi
			;;
		MODE_EQUALS_BEFORE)
			if bash_toml.is.equals_sign "$char"; then
				mode="MODE_ANY_BEFORE_VALUE"
			elif bash_toml.is.empty "$char"; then
				bash_toml.parse_fail 'UNEXPECTED_CHARACTER' "No equals sign found. End of file reached"
				return 1
			else
				bash_toml.parse_fail 'KEY_INVALID'
				return 1
			fi
			;;
		# directly after the `"`
		MODE_DOUBLEQUOTE_DURING_VALUE)

			# bash_toml.append_value_string "$char"
			;;
		# directly after the `'`
		MODE_SINGLEQUOTE_DURING_VALUE)
			if bash_toml.is.single_quote "$char"; then
				mode='MODE_ANY_AFTER_VALUE'
			elif bash_toml.is.newline "$char"; then
				bash_toml.parse_fail 'VALUE_STRING_INVALID' "Newlines are not valid in single quote"
				return 1
			else
				bash_toml.append_value_string "$char"
			fi
			;;
		MODE_ANY_AFTER_VALUE)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.newline "$char"; then
				mode='MODE_DEFAULT'
			elif bash_toml.is.empty "$char"; then
				mode='MODE_DEFAULT'
			else
				bash_toml.parse_fail 'UNEXPECTED_CHARACTER' "Newline expected"
				return 1
			fi
			;;
		esac
	done

	case "$mode" in
	MODE_DEFAULT)
		# i.g. ``
		:
		;;
	MODE_ANY_BEFORE_VALUE)
		bash_toml.parse_fail 'UNEXPECTED_BRANCH' "Key name found without value theta"
		return 1
		;;
	MODE_BAREKEY_DURING_KEY)
		#  i.g. `keyName`
		bash_toml.parse_fail 'UNEXPECTED_BRANCH' "Key name found without value"
		return 1
		;;
	MODE_EQUALS_BEFORE)
		;;
	esac

	TOML["$BASH_TOML_KEY_STRING"]="$BASH_TOML_KEY_VALUE_STRING"
}
