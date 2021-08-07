#!/usr/bin/env bats

load './util/init.sh'

@test "succeeds on empty 1" {
	run bash_toml.do_parse < <(printf '')

	assert_success
}

@test "succeeds on empty 2" {
	run bash_toml.do_parse  < <(printf '\n')

	assert_success
}

@test "succeeds on empty 3" {
	run bash_toml.do_parse  < <(printf ' ')

	assert_success
}

@test "succeeds on empty 4" {
	run bash_toml.do_parse  < <(printf ' \n')

	assert_success
}

@test "succeeds on empty 5" {
	run bash_toml.do_parse  < <(printf ' \n    \t\n\t  \n\n  ')

	assert_success
}
