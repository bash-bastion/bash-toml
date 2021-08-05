# shellcheck shell=bash

bash_toml.do_parse() {
	TOML_ERROR=
	TOML_MANUAL_ERROR='no'

	declare char=
	declare mode='MODE_DEFAULT'
	declare -i PARSER_LINE_NUMBER=0
	declare -i PARSER_COLUMN_NUMBER=0

	while IFS= read -rn 1 char; do
		if bash_toml.is.newline "$char"; then
			PARSER_LINE_NUMBER+=1
			PARSER_COLUMN_NUMBER=0
		else
			PARSER_COLUMN_NUMBER+=1
		fi

		bash_toml.debug

		case "$mode" in
		MODE_DEFAULT)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.newline "$char"; then
				:
			elif bash_toml.is.table "$char"; then
				bash_toml.die "Tables are not supported"
				return 1
			elif bash_toml.is.double_quote "$char"; then
				bash_toml.die "Quoted keys are not supported"
				return 1
			elif bash_toml.is.valid_bare_key_char "$char"; then
				bash_toml.init_key_string "$char"
				mode="DURING_BARE_KEY"
			else
				bash_toml.die "Character '$char' is not valid in this context"
				return 1
			fi
			;;
		BEFORE_SOME_VALUE)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.newline "$char"; then
				# TODO: not being fired?
				bash_toml.die "Key name found without value 2"
				return 1
			elif bash_toml.is.double_quote "$char"; then
				bash_toml.die "Double quote values are not supported"
				return 1
				mode='DURING_VALUE_DOUBLE_QUOTE'
				bash_toml.init_value_string
			elif bash_toml.is.single_quote "$char"; then
				mode='DURING_VALUE_SINGLE_QUOTE'
				bash_toml.init_value_string
			elif bash_toml.is.empty "$char"; then
				bash_toml.die "Expected value"
				return 1
			else
				bash_toml.die "Datetime, Boolean, Float, Integer, Array, Inline Table, etc. etc. Are not supported"
				return 1
			fi
			;;
		AFTER_ANY_VALUE)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.newline "$char"; then
				mode='MODE_DEFAULT'
			elif bash_toml.is.empty "$char"; then
				mode='MODE_DEFAULT'
			else
				bash_toml.die "Newline expected"
				return 1
			fi
			;;
		# directly after the `"`
		DURING_VALUE_DOUBLE_QUOTE)

			# bash_toml.append_value_string "$char"
			;;
		# directly after the `'`
		DURING_VALUE_SINGLE_QUOTE)
			if bash_toml.is.single_quote "$char"; then
				mode='AFTER_ANY_VALUE'
			elif bash_toml.is.newline "$char"; then
				bash_toml.die "Newlines are not valid in single quote"
				return 1
			else
				bash_toml.append_value_string "$char"
			fi
			;;
		DURING_BARE_KEY)
			if bash_toml.is.whitespace "$char"; then
				mode="BEFORE_KEY_EQUALS"
			elif bash_toml.is.newline "$char"; then
				bash_toml.die "Key name found without value"
				return 1
			elif bash_toml.is.valid_bare_key_char "$char"; then
				bash_toml.append_key_string "$char"
			elif bash_toml.is.empty "$char"; then
				bash_toml.die "Cannot reach end of file right now, have not finished parsing key"
				return 1
			else
				bash_toml.die "Character '$char' is not valid in this context"
				return 1
			fi
			;;
		BEFORE_KEY_EQUALS)
			if bash_toml.is.equals_sign "$char"; then
				mode="BEFORE_SOME_VALUE"
			elif bash_toml.is.empty "$char"; then
				bash_toml.die "No equals sign found. End of file reached"
				return 1
			else
				bash_toml.die "Expected equals sign; not '$char'"
				return 1
			fi
		esac
	done

	case "$mode" in
	MODE_DEFAULT)
		# i.g. ``
		:
		;;
	BEFORE_SOME_VALUE)
		bash_toml.die "Key name found without value theta"
		return 1
		;;
	DURING_BARE_KEY)
		#  i.g. `keyName`
		bash_toml.die "Key name found without value"
		return 1
		;;
	BEFORE_KEY_EQUALS)
		;;
	esac

	TOML["$BASH_TOML_KEY_STRING"]="$BASH_TOML_KEY_VALUE_STRING"
}
