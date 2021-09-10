# shellcheck shell=bash

bash-toml() {
	# shellcheck disable=SC1007
	local setPipefail= setGlobasciiranges= oldLcAll=

	if [ -o pipefail ]; then
		setPipefail='yes'
	else
		setPipefail='no'
	fi

	if shopt -q globasciiranges; then
		setGlobasciiranges='yes'
	else
		setGlobasciiranges='no'
	fi

	oldLcAll="$LC_ALL"
	LC_ALL="en_US.UTF-8"

	for arg; do
		case "$arg" in
		stdin)
			bash_toml.parse
			;;
		file)
			bash_toml.parse < "$2"
			;;
		string)
			bash_toml.parse <<< "$2"
			;;
		esac
	done

	if [ "$setPipefail" ]; then
		set -o pipefail
	else
		set +o pipefail
	fi

	if [ "$setGlobasciiranges" ]; then
		shopt -s globasciiranges
	else
		shopt -u globasciiranges
	fi

	LC_ALL="$oldLcAll"
}
