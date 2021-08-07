#!/usr/bin/env bats

load './util/init.sh'

@test "fails on invalid comment 1" {
	run bash_toml.do_parse < <(printf 'k = # comment')

	assert_failure
	assert_output -p "NOT_IMPLEMENTED"
}

@test "succeeds on valid comment 1" {
	run bash_toml.do_parse < <(printf '# comment uwu')

	assert_success
}

@test "succeeds on valid comment 2" {
	run bash_toml.do_parse <<-"EOF"
	# comment uwu
	EOF

	assert_success
}

@test "succeeds on valid comment 3" {
	bash_toml.do_parse <<-"EOF"
	k = 'woof' # comment
	EOF

	assert test_util.toml.has_key 'k'
	assert test_util.toml.key_has_value 'k' 'woof'
}

@test "succeeds on valid comment 4" {
	bash_toml.do_parse <<-"EOF"
	k = "WOOF" # comment
	EOF

	assert test_util.toml.has_key 'k'
	assert test_util.toml.key_has_value 'k' 'WOOF'
}
