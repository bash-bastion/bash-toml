# shellcheck shell=bash

test_util.get_root() {
	REPLY=
	if ! REPLY="$(
		while [[ ! -d ".git" && "$PWD" != / ]]; do
			if ! cd ..; then
				printf "%s\n" "Error: Could not cd to BPM directory" >&2
				exit 1
			fi
		done
		if [[ $PWD == / ]]; then
			printf "%s\n" "Error: Could not find root BPM directory" >&2
			exit 1
		fi

		printf "%s" "$PWD"
	)"; then
		exit 1
	fi
}
