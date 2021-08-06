#!/usr/bin/env bats

load './util/init.sh'

@test "succeeds on empty 1" {
	printf '' | bash_toml.do_parse
}

@test "succeeds on empty 2" {
	printf ' ' | bash_toml.do_parse
}

@test "succeeds on empty 3" {
	printf ' \n' | bash_toml.do_parse
}

@test "succeeds on empty 4" {
	printf ' \n    \t\n\t  \n\n  ' | bash_toml.do_parse
}

@test "succeeds on empty 5" {
	run bash_toml.do_parse <<< ""

	assert_success
}

@test "succeeds on empty 6" {
	run bash_toml.do_parse <<"EOF"
EOF

	assert_success
}
