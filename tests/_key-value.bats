#!/usr/bin/env bats

load './util/init.sh'

@test basic key value tests {
	declare -A arr=()

	arr[kkey]="vvalue"

	run test_util.object_has_key arr kkey
	assert_success

	run test_util.object_has_key arr kkkey
	assert_failure

	run test_util.object_has_key_and_value arr kkey vvalue
	assert_success

	run test_util.object_has_key_and_value arr kkkey
	assert_failure

	run test_util.object_has_key_and_value arr kkey vvalue2
	assert_failure
}
