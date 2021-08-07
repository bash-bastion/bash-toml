load './util/init.sh'

@test "fails on invalid literal string 1" {
	run bash_toml.do_parse <<-"EOF"
	fox = '''
	EOF

	assert_failure
	assert_output -p "UNEXPECTED_CHARACTER"
}

@test "succeeds on valid literal string 1" {
	bash_toml.do_parse <<-"EOF"
	fox = 'value'
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' 'value'
}

@test "succeeds on valid literal string 2" {
	bash_toml.do_parse <<-"EOF"
	fox = 'val ue'
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' 'val ue'
}

@test "succeeds on valid literal string 3" {
	bash_toml.do_parse <<-"EOF"
	fox = '"'
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' '"'
}

@test "succeeds on valid literal string 4" {
	bash_toml.do_parse <<-"EOF"
	fox = '\a\n\four'
	EOF

	assert test_util.toml.has_key 'fox'
	assert test_util.toml.key_has_value 'fox' '\a\n\four'
}
