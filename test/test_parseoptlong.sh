#!/bin/sh

cd "${0%/*}" || exit

. ./helper.sh
. ../lib/parseoptlong.sh

test1 () {
    local OPTIND=1 opt arg colon

    if [ "$1" = : ]; then
        colon=:
        shift
    fi

    parseoptlong=`parseoptlong $colon help verbose user: password= opt`

    while getopts hvu:-: opt; do
        eval "$parseoptlong"
        case "$opt" in
            h|help|v|verbose)
                echo $opt${OPTARG:++}
                ;;
            u|user)
                echo "u=$OPTARG"
                ;;
            password)
                if [ -n "${OPTARG+t}" ]; then
                    echo "P=$OPTARG"
                else
                    echo P
                fi
                ;;
            *)
                if [ -n "${OPTARG+t}" ]; then
                    echo "error=$opt,$OPTARG"
                else
                    echo "error=$opt"
                fi
                return 64
                ;;
        esac
    done

    shift $((OPTIND-1))

    for arg; do
        echo "arg=$arg"
    done
}

assert_command_output 'normal case' 0 \
'verbose
v
u=xyz
P
P=
u=aa
arg=bb
arg=cc
' \
'' \
test1 --verbose -vuxyz --password --password= --user aa bb cc

assert_command_output 'normal case with colon' 0 \
'verbose
v
u=xyz
P
P=
u=aa
arg=bb
arg=cc
' \
'' \
test1 : --verbose -vuxyz --password --password= --user aa bb cc

assert_command_output 'error case 1' 64 \
'v
error=?
' \
"$0: illegal option -- -
" \
test1 -v-user aa bb

assert_command_output 'error case 1 with colon' 64 \
'v
error=?,-
' \
'' \
test1 : -v-user aa bb

assert_command_output 'error case 2' 64 \
'error=?
' \
"$0: option requires an argument -- user
" \
test1 --user

assert_command_output 'error case 2 with colon' 64 \
'error=:,user
' \
'' \
test1 : --user
