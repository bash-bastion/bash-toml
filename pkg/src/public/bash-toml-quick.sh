# shellcheck shell=bash

bash_toml.quick_string_get() {
	unset -v REPLY; REPLY=
	local toml_file="$1"
	local key_name="$2"

	if [ ! -f "$toml_file" ]; then
		bash_toml.error "File '$toml_file' not found"
		return 1
	fi

	local regex=$'^[ \t]*'${key_name}$'[ \t]*=[ \t]*[\047"](.*)[\047\"]'
	local grep_line=
	while IFS= read -r line || [ -n "$line" ]; do
		if [[ $line =~ $regex ]]; then
			grep_line="$line"
			break
		fi
	done < "$toml_file"

	# If the grep_line is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grep_line" ]; then
		REPLY=''
		return 1
	fi

	if [[ $grep_line =~ $regex ]]; then
		REPLY="${BASH_REMATCH[1]}"
	else
		# This should not happen due to the '[[ $line == *"$key_name"*=* ]]' check above
		bash_toml.error "Could not find key '$key_name' in file '$toml_file'"
		return 1
	fi
}

bash_toml.quick_array_get() {
	unset REPLY; declare -ga REPLY=()
	local toml_file="$1"
	local key_name="$2"

	# ensure.nonzero 'toml_file'
	# ensure.nonzero 'key_name'

	if [ ! -f "$toml_file" ]; then
		bash_toml.error "File '$toml_file' does not exist"
		return 2
	fi

	local parse_mode=
	local grep_line=
	while IFS= read -r line || [ -n "$line" ]; do
		if [ "$parse_mode" = 'collect' ]; then
			grep_line+="$line"

			if [[ $line == *$'\135'* ]]; then
				break
			fi
			continue
		fi

		# FIXME: this should be regex so it does not greedily match
		# ex. if getting 'somekey', the value of 'somekey33' could be returned
		if [[ $line == *"$key_name"*=*$'\133'*$'\135'* ]]; then
			grep_line="$line"
			break
		elif [[ $line == *"$key_name"*=*$'\133'* ]]; then
			grep_line="$line"
			parse_mode='collect'
		fi
	done < "$toml_file"
	unset -v parse_mode

	# If the grep_line is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grep_line" ]; then
		REPLY=''
		return 1
	fi

	local regex=
	printf -v regex '[ \t]*%s[ \t]*=[ \t]*\[[ \t]*(.*)[ \t]*\]' "$key_name"
	if [[ $grep_line =~ $regex ]]; then
		local -r arrayString="${BASH_REMATCH[1]}"

		IFS=',' read -ra REPLY <<< "$arrayString"
		for i in "${!REPLY[@]}"; do
			# Treat all Toml strings the same; there shouldn't be
			# any escape characters anyways
			local regex="[ \t]*['\"](.*)['\"]"
			if [[ ${REPLY[$i]} =~ $regex ]]; then
				REPLY[$i]="${BASH_REMATCH[1]}"
			else
				bash_toml.error "Key '$key_name' in file '$toml_file' is not valid"
				return 2
			fi
		done
	else
		bash_toml.error "Key '$key_name' in file '$toml_file' must be set to an array that spans one line"
		return 2
	fi
}

bash_toml.quick_string_set() {
	:
}

bash_toml.quick_array_append() {
	local toml_file="$1"
	local key_name="$2"
	local key_value="$3"

	# ensure.nonzero 'toml_file'
	# ensure.nonzero 'key_value'

	if [ ! -f "$toml_file" ]; then
		bash_toml.error "File '$toml_file' does not exist"
		return 2
	fi

	if util.get_toml_array "$toml_file" 'dependencies'; then
		local name=
		for name in "${REPLY[@]}"; do
			if [ "${name%@*}" = "${key_value%@*}" ]; then
				bash_toml.error "A version of '${name%@*}' is already installed. Skipping"
				return 2
			fi
		done; unset name

		if ((${#REPLY[@]} == 0)); then
			mv "$toml_file" "$toml_file.bak"
			sed -e "s,\([ \t]*dependencies[ \t]*=[ \t]*.*\)\],\1'${key_value}']," "$toml_file.bak" > "$toml_file"
			rm "$toml_file.bak"
		else
			mv "$toml_file" "$toml_file.bak"
			sed -e "s,\([ \t]*dependencies[ \t]*=[ \t]*.*\(['\"]\)\),\1\, \2${key_value}\2," "$toml_file.bak" > "$toml_file"
			rm "$toml_file.bak"
		fi
	else
		bash_toml.error "Key 'dependencies' not found in file '$toml_file'"
		return 2
	fi
}

bash_toml.quick_array_remove() {
	local toml_file="$1"
	local key_value="$2"

	# ensure.nonzero 'toml_file'
	# ensure.nonzero 'key_value'

	if [ ! -f "$toml_file" ]; then
		bash_toml.error "File '$toml_file' does not exist"
		return 2
	fi

	if util.get_toml_array "$toml_file" 'dependencies'; then
		local dependency_array=()
		local does_exist='no'
		local name=
		for name in "${REPLY[@]}"; do
			if [ "${name%@*}" = "${key_value%@*}" ]; then
				does_exist='yes'
			else
				dependency_array+=("$name")
			fi
		done; unset -v name

		if [ "$does_exist" != 'yes' ]; then
			bash_toml.error "The package '$key_value' is not currently a dependency"
			return 2
		fi

		mv "$toml_file" "$toml_file.bak"
		while IFS= read -r line || [ -n "$line" ]; do
			if [[ "$line" == *dependencies*=* ]]; then
				local new_line='dependencies = ['
				local dep=
				for dep in "${dependency_array[@]}"; do
					printf -v new_line "%s'%s', " "$new_line" "$dep"
				done; unset dep

				new_line="${new_line%, }]"
				printf '%s\n' "$new_line"
			else
				printf '%s\n' "$line"
			fi
		done < "$toml_file.bak" > "$toml_file"
		rm "$toml_file.bak"
	else
		bash_toml.error "Key 'dependencies' not found in file '$toml_file'"
		return 2
	fi
}

bash_toml.quick_array_replace() {
	:
}
