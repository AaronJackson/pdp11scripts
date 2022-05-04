#!/bin/bash

function b2w () { # 2 bytes to word
    h1=$(printf "%02x" $1 | tr 'a-f' 'A-F')
    h2=$(printf "%02x" $2 | tr 'a-f' 'A-F')
    echo "obase=8; ibase=16; $h1$h2" | bc
}

function i2w () { # int to 16 bit word
    echo "obase=8; ibase=10; $1" | bc
}

function cc2w () { # two chars to 16 bit word
    c1=$(printf '%d' "'$1")
    c1=$(printf "%02x" $c1 | tr 'a-f' 'A-F')
    c2=$(printf '%d' "'$2")
    c2=$(printf "%02x" $c2 | tr 'a-f' 'A-F')
    echo "obase=8; ibase=16; $c2$c1" | bc
}


function fcbit () {
    shift
    b2w 2 25 # 2 args FCBIT
    i2w $1
    i2w $2
}
function fcblk () {
    shift
    b2w $# 24 # args FCBLK
    for a in "$@" ; do
	i2w $a
    done
}
function fceli () {
    shift
    b2w $# 27 # args FCELI
    for a in "$@" ; do
	i2w $a
    done
}
function fcflo () {
    shift
    b2w 2 37 # 2 args FCFLO
    i2w $1
    i2w $2
}
function fcpix () {
    b2w 0 12
}
function fcrub () {
    shift
    b2w $# 6 # args FCRUB
    for a in "$@" ; do
	i2w $a
    done
}
function fcsel () {
    shift
    b2w $# 5 # args FCSEL
    for a in "$@" ; do
	i2w $a
    done
}
function fcvec () {
    shift
    b2w $# 23 # args FCVEC
    for a in "$@" ; do
	i2w $a
    done
}
function fcalp () {
    shift

    str="$3"
    if [ $(( ${#str} % 2 )) -eq 1 ] ; then
	str="$str "
    fi

    b2w 4 29 # 4 args FCALP
    i2w $1 # x coord
    i2w $2 # y coord
    i2w ${#str} # string length

    echo "$str" | fold -b2 | \
	while read word ; do
	    cc2w ${word:0:1} ${word:1:1}
	done
}

function parse_line () {
    case "$1" in
	BIT) fcbit $@ ;;
	BLK) fcblk $@ ;;
	ELI) fceli $@ ;;
	FLO) fcflo $@ ;;
	PIX) fcpix $@ ;;
	RUB) fcrub $@ ;;
	SEL) fcsel $@ ;;
	VEC) fcvec $@ ;;
	ALP) fcalp $@ ;;
	*) ;;
    esac

}

function memory_locs () {
    cat -n | \
	while read loc word ; do
	    loc=$(echo "obase=8; ibase=10; 512+($loc*2)" | bc)
	    echo deposit $loc $word
	done
}

function cmd_ambles () { # pre and post amble
    all=$(cat)
    words=$(echo "$all" | wc -l)
    words=$(echo "obase=8; ibase=10; 512+($words*2)+2" | bc)
    bytes=$(echo "obase=8; ibase=8; $words*2" | bc)
    echo deposit 1000 $bytes
    echo "$all"
    echo deposit $words 177777
    echo deposit 17760046 0
    echo deposit 17760044 2
    echo deposit 17760042 0
}

sed 's/\s*$//' | \
    grep '^\~' | \
    sed 's/^~//' | \
    while read -r line ; do
	parse_line $line
    done | \
	memory_locs | \
	cmd_ambles
