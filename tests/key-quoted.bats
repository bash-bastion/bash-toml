#!/usr/bin/env bats

load './util/init.sh'

@test "fails on invalid quoted key" {
	run bash_toml.do_parse <<< '"'

	assert_failure
	assert_output -p 'KEY_INVALID'
}

@test "fails on invalid quoted key 2" {
	run bash_toml.do_parse <<< $'"\n'

	assert_failure
	assert_output -p 'KEY_INVALID'
}

@test "fails on invalid quoted key 3" {
	run bash_toml.do_parse <<< '""'

	assert_failure
	assert_output -p 'UNEXPECTED_EOF'
}

@test "fails on invalid quoted key 4" {
	run bash_toml.do_parse <<< '""='

	assert_failure
	assert_output -p 'UNEXPECTED_EOF'
}

@test "fails on invalid quoted key 5" {
	run bash_toml.do_parse <<< '"" ='

	assert_failure
	assert_output -p 'UNEXPECTED_EOF'
}

@test "fails on invalid quoted key 6" {
	run bash_toml.do_parse <<< \"\"\ =\'

	assert_failure
	assert_output -p 'UNEXPECTED_EOF'
}

@test "succeeds on valid quoted key 1" {
	bash_toml.do_parse <<-"EOF"
	"" = 'UwU'
	EOF
}

@test "succeeds on valid quoted key 2" {
	bash_toml.do_parse <<-"EOF"
	"fox" = 'UwU'
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' 'UwU'
}
