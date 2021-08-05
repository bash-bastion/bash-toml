# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob globasciiranges

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
