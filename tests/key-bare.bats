#!/usr/bin/env bats

load './util/init.sh'

@test "fails on invalid bare key" {
	run bash_toml.do_parse <<-"EOF"
	fox
	EOF

	assert_failure
	assert_output -p 'KEY_INVALID'
}

@test "fails on invalid bare key 2" {
	run bash_toml.do_parse <<-"EOF"
	f ox
	EOF

	assert_failure
	assert_output -p 'KEY_INVALID'
}

@test "fails on invalid bare key 3" {
	run bash_toml.do_parse <<-"EOF"
	f!ox
	EOF

	assert_failure
	assert_output -p 'UNEXPECTED_CHARACTER'
}

@test "fails on invalid bare key 4" {
	run bash_toml.do_parse <<-"EOF"
	fox=
	EOF

	assert_failure
	assert_output -p 'UNEXPECTED_EOF'
}

@test "succeeds on valid bare key 1" {
	bash_toml.do_parse <<-"EOF"
	fox = 'value'
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' 'value'
}
