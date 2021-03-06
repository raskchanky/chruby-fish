. ./share/chruby/auto.sh
. ./test/helper.sh

TEST_DIR="$PWD"
PROJECT_DIR="$PWD/test/project"

setUp()
{
	chruby_reset
	unset RUBY_VERSION_FILE
}

test_chruby_auto_loaded_in_zsh()
{
	[[ -n "$ZSH_VERSION" ]] || return

	assertEquals "did not add chruby_auto to preexec_functions" \
		     "chruby_auto" \
		     "$preexec_functions"
}

test_chruby_auto_loaded_in_bash()
{
	[[ -n "$BASH_VERSION" ]] || return

	local output="$($SHELL -c ". ./share/chruby/auto.sh && trap -p DEBUG")"

	assertTrue "did not add a trap hook for chruby_auto" \
		   '[[ "$output" == *chruby_auto* ]]'
}

test_chruby_auto_loaded_twice_in_zsh()
{
	[[ -n "$ZSH_VERSION" ]] || return

	. ./share/chruby/auto.sh

	assertNotEquals "should not add chruby_auto twice" \
		        "$preexec_functions" \
			"chruby_auto chruby_auto"
}

test_chruby_auto_loaded_twice()
{
	RUBY_VERSION_FILE="dirty"
	PROMPT_COMMAND="chruby_auto"

	. ./share/chruby/auto.sh

	assertNull "RUBY_VERSION_FILE was not unset" "$RUBY_VERSION_FILE"
}

test_chruby_auto_enter_project_dir()
{
	cd "$PROJECT_DIR" && chruby_auto >/dev/null

	assertEquals "did not switch Ruby when entering a versioned directory" \
		     "$TEST_RUBY_ROOT" "$RUBY_ROOT"
}

test_chruby_auto_enter_subdir_directly()
{
	cd "$PROJECT_DIR/sub_dir" && chruby_auto >/dev/null

	assertEquals "did not switch Ruby when directly entering a sub-directory of a versioned directory" \
		     "$TEST_RUBY_ROOT" "$RUBY_ROOT"
}

test_chruby_auto_enter_subdir()
{
	cd "$PROJECT_DIR" && chruby_auto >/dev/null
	cd sub_dir        && chruby_auto

	assertEquals "did not keep the current Ruby when entering a sub-dir" \
		     "$TEST_RUBY_ROOT" "$RUBY_ROOT"
}

test_chruby_auto_enter_subdir_with_ruby_version()
{
	cd "$PROJECT_DIR" && chruby_auto >/dev/null
	cd sub_versioned/ && chruby_auto

	assertNull "did not switch the Ruby when leaving a sub-versioned directory" \
		   "$RUBY_ROOT"
}

test_chruby_auto_overriding_ruby_version()
{
	cd "$PROJECT_DIR" && chruby_auto >/dev/null
	chruby system     && chruby_auto

	assertNull "did not override the Ruby set in .ruby-version" "$RUBY_ROOT"
}

test_chruby_auto_leave_project_dir()
{
	cd "$PROJECT_DIR"    && chruby_auto >/dev/null
	cd "$PROJECT_DIR/.." && chruby_auto

	assertNull "did not reset the Ruby when leaving a versioned directory" \
		   "$RUBY_ROOT"
}

test_chruby_auto_invalid_ruby_version()
{
	cd "$PROJECT_DIR" && chruby_auto >/dev/null
	cd bad/           && chruby_auto 2>/dev/null

	assertEquals "did not keep the current Ruby when loading an unknown version" \
		     "$TEST_RUBY_ROOT" "$RUBY_ROOT"
}

tearDown()
{
	cd "$TEST_DIR"
}

SHUNIT_PARENT=$0 . $SHUNIT2
