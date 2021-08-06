# shellcheck shell=bash

# TODOD: ensure shopt options are set back / remove set
set -ETeo pipefail
shopt -s nullglob extglob globasciiranges
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
}
