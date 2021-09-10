#!/usr/bin/env bash

source './pkg/bin/bash-toml.sh'

declare -A TOML=()
bash-toml string "theta = 'UwU'"

for key in "${!TOML[@]}"; do
	printf '%s\n' "TOML[$key] = ${TOML["$key"]}"
done
