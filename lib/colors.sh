#Black       0;30     Dark Gray     1;30
#Blue        0;34     bright Blue    1;34
#Green       0;32     bright Green   1;32
#Cyan        0;36     bright Cyan    1;36
#Red         0;31     bright Red     1;31
#Purple      0;35     bright Magenta  1;35
#Brown       0;33     Yellow        1;33
#bright Gray  0;37     White         1;37

export ccdefault="0"
export ccblack="0;30"
export ccdarkgrey="1;30"
export ccred="0;31"
export ccbrightred="1;31"
export ccgreen="0;32"
export ccbrightgreen="1;32"
export ccyellow="0;33"
export ccbrightyellow="1;33"
export ccblue="0;34"
export ccbrightblue="1;34"
export ccmagenta="0;35"
export ccbrightmagenta="1;35"
export cccyan="0;36"
export ccbrightcyan="1;36"
export ccwhite="0;37"
export ccbrightwhite="1;37"

function color {
	color=$1
	shift;
	start=$(colorencode $color)
	end=$(colorencode default)
	if [[ "$@" == "" ]]
	then
		echo "`eval echo $start`"
	else
		echo "`eval echo $start'$@'$end`"
	fi
}

function colorencode {
	prefix='$(echo "[")'
	suffix='m'
	echo $prefix'${cc'$1'}'$suffix
}

function promptcolor {
	color=$1
	shift;
	start=$(promptcolorencode $color)
	end=$(promptcolorencode default)
	if [[ "$@" == "" ]]
	then
		echo "`eval echo $start`"
	else
		echo "`eval echo $start'$@'$end`"
	fi
}

function promptcolorencode {
	prefix='%{$(echo "[")'
	suffix='m%}'
	echo $prefix'${cc'$1'}'$suffix
}

# Shell colors
function default {
	color default $@
}

function black {
	color black $@
}

function darkgrey {
	color darkgrey $@
}

function red {
	color red $@
}

function brightred {
	color brightred $@
}

function green {
	color green $@
}

function brightgreen {
	color brightgreen $@
}

function yellow {
	color yellow $@
}

function brightyellow {
	color brightyellow $@
}

function blue {
	color blue $@
}

function brightblue {
	color brightblue $@
}

function magenta {
	color magenta $@
}

function brightmagenta {
	color brightmagenta $@
}

function cyan {
	color cyan $@
}

function brightcyan {
	color brightcyan $@
}

function white {
	color white $@
}

function brightwhite {
	color brightwhite $@
}

function maganda {
	brightmagenta $@
}

# Prompt colors
function defaultprompt {
	promptcolor default $@
}

function blackprompt {
	promptcolor black $@
}

function darkgreyprompt {
	promptcolor darkgrey $@
}

function redprompt {
	promptcolor red $@
}

function brightredprompt {
	promptcolor brightred $@
}

function greenprompt {
	promptcolor green $@
}

function brightredprompt {
	promptcolor brightred $@
}

function brightgreenprompt {
	promptcolor brightgreen $@
}

function yellowprompt {
	promptcolor yellow $@
}

function brightyellowprompt {
	promptcolor brightyellow $@
}

function blueprompt {
	promptcolor blue $@
}

function brightblueprompt {
	promptcolor brightblue $@
}

function magentaprompt {
	promptcolor magenta $@
}

function brightmagentaprompt {
	promptcolor brightmagenta $@
}

function cyanprompt {
	promptcolor cyan $@
}

function brightcyanprompt {
	promptcolor brightcyan $@
}

function whiteprompt {
	promptcolor white $@
}

function brightwhiteprompt {
	promptcolor brightwhite $@
}

function magandaprompt {
	brightmagentaprompt $@
}
