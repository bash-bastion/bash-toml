# shellcheck shell=bash

if [ -n "${DEBUG+x}" ]; then
	trap 'bash_toml.trap_error' 'ERR'
	bash_toml.trap_error() {
		bash_toml.debug
	}
fi
