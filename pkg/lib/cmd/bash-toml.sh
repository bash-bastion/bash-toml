# shellcheck shell=bash

if [ -n "${DEBUG+x}" ]; then
	trap 'bash_toml.trap_error' 'ERR'
	bash_toml.trap_error() {
		bash_toml.debug
	}
fi

for f in "$BASH_TOML_LIB_DIR"/util/?*.sh; do
	# shellcheck disable=SC1090
	source "$f"
done

bash-toml() {
	# shellcheck disable=SC1007
	local setPipefail= setGlobasciiranges=

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
}
