#!/usr/bin/env bats

load './util/init.sh'

@test "fails on invalid basic string 1" {
	run bash_toml.do_parse < <(printf 'fox = "')

	assert_failure
	assert_output -p "UNEXPECTED_EOF"
}

@test "fails on invalid basic string 2" {
	run bash_toml.do_parse < <(printf 'fox = "\n')

	assert_failure
	assert_output -p "UNEXPECTED_NEWLINE"
}

@test "fails on invalid basic string 3" {
	run bash_toml.do_parse < <(printf 'fox = "a')

	assert_failure
	assert_output -p "UNEXPECTED_EOF"
}

@test "fails on invalid basic string 4" {
	run bash_toml.do_parse < <(printf 'fox = "a\n')

	assert_failure
	assert_output -p "UNEXPECTED_NEWLINE"
}

@test "fails on invalid basic string 5" {
	run bash_toml.do_parse < <(printf 'fox = "ab')

	assert_failure
	assert_output -p "UNEXPECTED_EOF"
}

@test "fails on invalid basic string 6" {
	run bash_toml.do_parse < <(printf 'fox = "ab\n')

	assert_failure
	assert_output -p "UNEXPECTED_NEWLINE"
}

@test "fails on invalid basic string 7" {
	run bash_toml.do_parse <<< 'fox = "\j"'

	assert_failure
	assert_output -p "UNEXPECTED_CHARACTER"
}

@test "fails on invalid basic string 8" {
	for hex in D800 DFFF; do
		run bash_toml.do_parse <<< "fox = "\"\\u"$hex"\"

		assert_failure
		assert_output -p 'UNICODE_INVALID'
	done
}

@test "fails on invalid basic string 9" {
	run bash_toml.do_parse <<-"EOF"
	fox = "\U00110000"
	EOF

	assert_failure
	assert_output -p 'UNICODE_INVALID'
}

@test "succeeds on valid basic string 1" {
	bash_toml.do_parse <<-"EOF"
	fox = ""
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' ''
}

@test "succeeds on valid basic string 2" {
	bash_toml.do_parse <<-"EOF"
	fox = ":)"
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' ':)'
}

@test "succeeds on valid basic string 3" {
	bash_toml.do_parse <<-"EOF"
	fox = ": )"
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' ': )'
}

@test "succeeds on valid basic string 4" {
	bash_toml.do_parse <<< 'fox = "\t"'

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' $'\t'
}

@test "succeeds on valid basic string 5" {
	bash_toml.do_parse <<< 'fox = "\r"'

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' $'\u000D'
}

@test "succeeds on valid basic string 6" {
	bash_toml.do_parse <<< 'fox = "\""'

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' '"'
}

@test "succeeds on valid basic string 7" {
	bash_toml.do_parse <<< 'fox = "\\"'

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' '\'
}

@test "succeeds on valid basic string 8" {
	bash_toml.do_parse <<< 'fox = "\\"'

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' '\'
}

@test "succeeds on valid basic string 9" {
	bash_toml.do_parse <<< 'fox = "\u0061"'

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' 'a'
}

@test "succeeds on valid basic string 10" {
	for hex in 0000 D7FF E000; do
		run bash_toml.do_parse <<< "fox = "\"\\u"$hex"\"

		assert_success
	done
}

@test "succeeds on valid basic string 11" {
	bash_toml.do_parse <<-"EOF"
	fox = "\U000122B9"
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' '𒊹'
}


@test "succeeds on valid basic string 12" {
	bash_toml.do_parse <<-"EOF"
	meow = "\u0061pples\\ause"
	EOF

	assert test_util.toml.has_key 'meow'
	assert test_util.toml.key_has_value 'meow' 'apples\ause'
}
