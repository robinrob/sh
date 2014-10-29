source $SHCOLORS_PATH


function log {
  CMD=$1

  result=$(eval $CMD)
  echo "$(green)${CMD}: $(yellow)$result"
}
