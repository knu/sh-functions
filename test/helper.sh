assert_command_output () {
    local f1="$(mktemp /tmp/stdout.XXXXXX)" f2="$(mktemp /tmp/stderr.XXXXXX)"
    local title="$1" cr="$2" c1="$3" c2="$4"; shift 4
    local fail= r

    echo "<= $title"

    "$@" >"$f1" 2>"$f2"
    r=$?

    if [ $r -ne $cr ]; then
        echo "=> error: return value mismatch: actual=$r expected=$cr" >&2
        fail=t
    fi

    if ! printf %s "$c1" | diff -u - "$f1"; then
        echo "=> error: output to stdout mismatch" >&2
        fail=t
    fi

    if ! printf %s "$c2" | diff -u - "$f2"; then
        echo "=> error: output to stderr mismatch" >&2
        fail=t
    fi

    rm -f "$f1" "$f2"

    [ -z "$fail" ] && echo '=> ok'
}
