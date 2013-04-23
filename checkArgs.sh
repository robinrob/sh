# Check there is one argument which corresponds to a numerical directory name
# and that the directory is not empty!
[[ -d $1 && $1 != *[^0-9]* ]] || { echo "Invalid input." >&2; exit 1; }