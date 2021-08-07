# bash-toml

Toml v0.4.0 parser written in pure Bash

STATUS: EXPERIMENTAL

## Usage

```sh
declare -A TOML=()
source bash-toml <<-"EOF"
five = 'value'
EOF

printf '%s' "${TOML[five]}" # value
```

## Error Handling

1. Bail Fast

This means error handling is performed by `bash-toml`. More specifically, if there is a problem parsing, the script will exit. This is useful if you want to use `bash-toml` for a quick thing, and want to bail fast, irrespective of the `errexit` option. Of course, if you execute this in a subshell (potentially depending on the `pipefail` option), the main shell won't exit at all

```bash
# file.sh
set +e

source ./bash-toml.sh
bash-toml <<< "key = '"
```

```bash
$ ./file.sh # => exitCode 1
Error: Could not finish single quote string, etc.
```

2. Control

If you want to have more fine-grained control over your error handling

- Note that this does not currently mask error output to stdin that builtins may emit when erroring


```bash
# file.sh
set +e

source ./bash-toml.sh
TOML_MANUAL_ERROR='yes'
if ! bash-toml <<< "key = '"; then
	if [ -n "$TOML_ERROR" ]; then
		# Problem with the 'file.toml'
		:
	else
		# Internal 'bash-toml' error
		exit 2
	fi
fi
```

```bash
$ ./file.sh # => exitCode 0
```

## Caveats

- When parsing literal strings, i think actual literal control characters are not taken into account
- When parsing basic strings, any control characters that appear will show error "EOF" rather than one specific to control characters
  - this is generally true since no differentiation between a newline and EOF
