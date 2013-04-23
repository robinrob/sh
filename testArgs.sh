errorMsg="Invalid input.\nUsage: "$0" <src dir> <output>"
[[ -d $1 ]] || { echo -e $errorMsg >&2; exit 1; }