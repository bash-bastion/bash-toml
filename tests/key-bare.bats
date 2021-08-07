#!/usr/bin/env bats

load './util/init.sh'

@test "fails on invalid bare key 1" {
	run bash_toml.do_parse < <(printf 'fox')

	assert_failure
	assert_output -p 'UNEXPECTED_EOF'
}

@test "fails on invalid bare key 2" {
	run bash_toml.do_parse < <(printf 'fox\n')

	assert_failure
	assert_output -p 'KEY_INVALID'
}

@test "fails on invalid bare key 3" {
	run bash_toml.do_parse < <(printf 'f ox')

	assert_failure
	assert_output -p 'KEY_INVALID'
}

@test "fails on invalid bare key 4" {
	run bash_toml.do_parse < <(printf 'f!ox')

	assert_failure
	assert_output -p 'UNEXPECTED_CHARACTER'
}

@test "fails on invalid bare key 5" {
	run bash_toml.do_parse < <(printf 'fox=')

	assert_failure
	assert_output -p 'UNEXPECTED_EOF'
}

@test "fails on invalid bare key 6" {
	run bash_toml.do_parse < <(printf 'fox=\n')

	assert_failure
	assert_output -p 'UNEXPECTED_NEWLINE'
}

@test "succeeds on valid bare key 1" {
	bash_toml.do_parse <<-"EOF"
	fox = 'value'
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' 'value'
}

@test "succeeds on valid bare key 2" {
	bash_toml.do_parse <<-"EOF"
	123 = 'value'
	EOF

	assert test_util.toml.has_key '123'
	assert test_util.toml.key_has_value '123' 'value'
}
