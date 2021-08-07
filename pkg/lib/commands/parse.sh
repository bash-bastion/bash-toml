# shellcheck shell=bash

bash_toml.do_parse() {
	TOML_ERROR=
	TOML_MANUAL_ERROR='no'

	declare char=
	declare mode='MODE_DEFAULT'
	declare -i PARSER_LINE_NUMBER=1
	declare -i PARSER_COLUMN_NUMBER=0

	while IFS= read -rN1 char; do
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
			elif bash_toml.is.octothorp "$char"; then
				mode='MODE_IN_COMMENT'
			elif bash_toml.is.table "$char"; then
				bash_toml.parse_fail 'NOT_IMPLEMENTED' "Tables are not supported"
				return 1
			elif bash_toml.is.double_quote "$char"; then
				bash_toml.init_key_string ''
				mode='MODE_QUOTEDKEY_DURING_KEY'
			elif bash_toml.is.valid_bare_key_char "$char"; then
				bash_toml.init_key_string "$char"
				mode="MODE_BAREKEY_DURING_KEY"
			else
				# If after only gobbling up whitespace, and there is nothign left,
				# we are done
				return 0
			fi
			;;
		MODE_IN_COMMENT)
			if bash_toml.is.newline "$char"; then
				mode='MODE_DEFAULT'
			elif bash_toml.is.empty "$char"; then
				mode='MODE_DEFAULT'
			else
				:
			fi
			;;
		MODE_ANY_BEFORE_VALUE)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.double_quote "$char"; then
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
				bash_toml.init_value_string
			elif bash_toml.is.single_quote "$char"; then
				mode='MODE_SINGLEQUOTE_DURING_VALUE'
				bash_toml.init_value_string
			elif bash_toml.is.newline "$char"; then
				bash_toml.parse_fail 'UNEXPECTED_NEWLINE' 'Expected to find value on the same line'
			elif bash_toml.is.empty "$char"; then
				bash_toml.parse_fail 'UNEXPECTED_EOF' 'Expected to find value on the same line'
				return 1
			else
				bash_toml.parse_fail 'NOT_IMPLEMENTED' "Construct is not valid or not yet implemented"
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
		MODE_QUOTEDKEY_DURING_KEY)
			if bash_toml.is.double_quote "$char"; then
				mode="MODE_EQUALS_BEFORE"
			elif bash_toml.is.newline "$char"; then
				bash_toml.parse_fail 'KEY_INVALID' 'Quoted key was not finished on the same line'
				return 1
			elif bash_toml.is.empty "$char"; then
				bash_toml.parse_fail 'KEY_INVALID' 'Quoted key was not finished on the same line'
				return 1
			else
				bash_toml.append_key_string "$char"
			fi
			;;
		MODE_EQUALS_BEFORE)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.equals_sign "$char"; then
				mode="MODE_ANY_BEFORE_VALUE"
			elif bash_toml.is.empty "$char"; then
				bash_toml.parse_fail 'UNEXPECTED_EOF' "No equals sign found"
				return 1
			else
				bash_toml.parse_fail 'KEY_INVALID'
				return 1
			fi
			;;
		# directly after the `"`
		MODE_DOUBLEQUOTE_DURING_VALUE)
			if bash_toml.is.double_quote "$char"; then
				mode='MODE_DEFAULT_END'
			elif bash_toml.is.backslash "$char"; then
				mode='MODE_DOUBLEQUOTE_DURING_ESCAPE_SEQUENCE'
			elif bash_toml.is.newline "$char"; then
				bash_toml.parse_fail 'UNEXPECTED_NEWLINE' "Literal newlines must not be present in double quotes"
				return 1
			elif bash_toml.is.control_character "$char"; then
				# TODO: this code path won't get activated
				:
			else
				bash_toml.append_value_string "$char"
			fi
			;;
		# directly after any `\`
		MODE_DOUBLEQUOTE_DURING_ESCAPE_SEQUENCE)
			if [ "$char" = b ]; then
				bash_toml.append_value_string $'\b'
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
			elif [ "$char" = t ]; then
				bash_toml.append_value_string $'\t'
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
			elif [ "$char" = n ]; then
				bash_toml.append_value_string $'\n'
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
			elif [ "$char" = f ]; then
				bash_toml.append_value_string $'\f'
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
			elif [ "$char" = r ]; then
				bash_toml.append_value_string $'\u000D'
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
			elif [ "$char" = \" ]; then
				bash_toml.append_value_string \"
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
			elif [ "$char" = \\ ]; then
				bash_toml.append_value_string \\
				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
			elif [ "$char" = u ]; then
				local -i unicode_n_total_digits=4
				mode='MODE_DOUBLEQUOTE_DURING_ESCAPE_SEQUENCE_UNICODE_START'
			elif [ "$char" = U ]; then
				local -i unicode_n_total_digits=8
				mode='MODE_DOUBLEQUOTE_DURING_ESCAPE_SEQUENCE_UNICODE_START'
			else
				bash_toml.parse_fail 'UNEXPECTED_CHARACTER' "Encountered character '$char', which does not produce a valid escape sequence"
				return 1
			fi
			;;
		MODE_DOUBLEQUOTE_DURING_ESCAPE_SEQUENCE_UNICODE_START)
			local -i unicode_nth_digit=1
			local unicode_code_point=
			if bash_toml.is.hex_digit "$char"; then
				unicode_code_point+="$char"
				mode='MODE_DOUBLEQUOTE_DURING_ESCAPE_SEQUENCE_UNICODE_DURING'
			else
				bash_toml.parse_fail 'UNEXPECTED_CHARACTER' "Encountered character '$char', which is not a valid hex digit as part of a unicode scalar value"
				return 1
			fi
			;;
		MODE_DOUBLEQUOTE_DURING_ESCAPE_SEQUENCE_UNICODE_DURING)
			unicode_nth_digit=$((unicode_nth_digit+1))
			if bash_toml.is.hex_digit "$char"; then
				unicode_code_point+="$char"
			else
				bash_toml.parse_fail 'UNEXPECTED_CHARACTER' "Encountered character '$char', which is not a valid hex digit as part of a unicode scalar value"
				return 1
			fi

			if ((unicode_nth_digit == unicode_n_total_digits)); then
				local unicode_scalar_value=

				if ! printf -v unicode_scalar_value_decimal '%d' "0x$unicode_code_point"; then
					bash_toml.parse_fail 'UNICODE_INVALID' "Could not convert the unicode code point from a hexidecimal to decimal value"
					return 1
				fi

				# Fine since we check for 'bash_toml.is.hex_digit' for each digit
				# shellcheck disable=SC2059
				if (( unicode_n_total_digits == 4)); then
					if ! printf -v unicode_scalar_value "\u$unicode_code_point"; then
						bash_toml.parse_fail 'UNICODE_INVALID' "Could not convert the unicode code point to a unicode scalar value"
						return 1
					fi
				elif (( unicode_n_total_digits == 8)); then
					if ! printf -v unicode_scalar_value "\U$unicode_code_point"; then
						bash_toml.parse_fail 'UNICODE_INVALID' "Could not convert the unicode code point to a unicode scalar value"
						return 1
					fi
				fi

				# https://unicode.org/glossary/#unicode_scalar_value
				if ((unicode_scalar_value_decimal >= 16#0 && unicode_scalar_value_decimal <= 16#D7FF)) \
						|| ((unicode_scalar_value_decimal >= 16#E000 && unicode_scalar_value_decimal <= 16#10FFFF)); then
					bash_toml.append_value_string "$unicode_scalar_value"
				else
					bash_toml.parse_fail 'UNICODE_INVALID' "The unicode code point is not a valid unicode scalar value"
				fi

				mode='MODE_DOUBLEQUOTE_DURING_VALUE'
				unset unicode_n_total_digits
			fi
			;;
		# directly after the `'`
		MODE_SINGLEQUOTE_DURING_VALUE)
			if bash_toml.is.single_quote "$char"; then
				mode='MODE_DEFAULT_END'
			elif bash_toml.is.newline "$char"; then
				bash_toml.parse_fail 'UNEXPECTED_NEWLINE' "Newlines are not valid in single quote"
				return 1
			elif bash_toml.is.empty "$char"; then
				bash_toml.parse_fail 'UNEXPECTED_EOF' "Must complete the literal string with a single quote"
				return 1
			else
				bash_toml.append_value_string "$char"
			fi
			;;
		MODE_DEFAULT_END)
			if bash_toml.is.whitespace "$char"; then
				:
			elif bash_toml.is.newline "$char"; then
				mode='MODE_DEFAULT'
			elif bash_toml.is.empty "$char"; then
				mode='MODE_DEFAULT'
			elif bash_toml.is.octothorp "$char"; then
				mode='MODE_IN_COMMENT'
			else
				bash_toml.parse_fail 'UNEXPECTED_CHARACTER' "Encountered character '$char' when a newline was expected"
				return 1
			fi
			;;
		esac
	done

	case "$mode" in
		MODE_DEFAULT|MODE_DEFAULT_END)
			;;
		*)
			bash_toml.parse_fail 'UNEXPECTED_EOF' 'Did not finish parsing construct'
			return 1
			;;
	esac
	# If we try to set an empty key with a value, then later on,
	# we can access any value (using a non-integer key), and we
	# will get a result that equals the original value value
	if [ -n "$BASH_TOML_KEY_STRING" ]; then
		TOML["$BASH_TOML_KEY_STRING"]="$BASH_TOML_KEY_VALUE_STRING"
	fi
}
