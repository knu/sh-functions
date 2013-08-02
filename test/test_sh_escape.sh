#!/bin/sh

cd "${0%/*}" || exit

. ./helper.sh
. ../lib/sh_escape.sh

args () {
    local arg i=0
    for arg; do
        i=$((i+1))
        printf '%d:[%s]\n' "$i" "$arg"
    done
}

assert_command_output 'white space' 0 \
'1:[	a]
2:[  b  c  ]
3:[d
e]
' \
'' \
eval args "$(sh_escape "	a")" "$(sh_escape "  b  c  ")" "$(sh_escape "d
e")"

assert_command_output 'quotation' 0 \
'1:[a'\''b]
2:[c"d]
' \
'' \
eval args "$(sh_escape "a'b")" "$(sh_escape "c\"d")"

assert_command_output 'nested space, quotation and backslash' 0 \
'1:[a '\''b]
2:[c" d]
3:[e\f]
' \
'' \
eval args "$(eval "$(sh_escape printf "%s %s %s" "$(sh_escape "a 'b")" "$(sh_escape "c\" d")" "$(sh_escape "e\\f")")")"
