set -e RUBY_VERSION_FILE

function chruby_auto --on-event fish_prompt
	set -l dir (pwd)
	set -l version_file ''

  set version_file "$dir/.ruby-version"

  if test "$version_file" = "$RUBY_VERSION_FILE"; return
  else if test -f "$version_file"
    chruby (cat "$version_file"); or return 1

    set -gx RUBY_VERSION_FILE "$version_file"
    return
  end
end
