#!/usr/bin/env bats

load './util/init.sh'

@test "fails on incomplete key" {
	run bash_toml.do_parse <<-"EOF"
	fox
	EOF

	assert_failure
	assert_output -p 'INCOMPLETE_KEY'
}

@test "fails on incomplete key 2" {
	run bash_toml.do_parse <<-"EOF"
	f ox
	EOF

	assert_failure
	assert_output -p 'INVALID_KEY'
}

@test "fails on incomplete key 3" {
	run bash_toml.do_parse <<-"EOF"
	fox=
	EOF

	assert_failure
	assert_output -p 'INCOMPLETE_VALUE_ANY'
}
