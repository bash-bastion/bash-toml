#!/usr/bin/env bats

load './util/init.sh'

@test "fails on invalid key 4" {
	run bash_toml.do_parse <<-"EOF"
	fox=
	EOF

	assert_failure
	assert_output -p 'VALUE_STRING_INVALID'
}
