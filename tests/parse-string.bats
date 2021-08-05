#!/usr/bin/env bats

load './util/init.sh'

@test "string single quote" {
	bash_toml.do_parse <<-"EOF"
	somekey = 'somevalue'
	EOF

	assert_success
	test_util.object_has_key_and_value 'somekey' 'somevalue'
}
