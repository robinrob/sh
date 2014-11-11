source $ZSHCOLORS_PATH


function log {
  CMD=$1

  if [[ -n $CMD ]]
  then  
    printf "$(green)$CMD: $(yellow)$(eval $CMD)"
  fi
  printf "\n"
}

function logb {
  CMD=$1

  if [[ -n $CMD ]]
  then  
    printf "$(green)$CMD: \n$(yellow)$(eval $CMD)"
  fi
  printf "\n"
}

function lognl {
  log $@
  printf "\n"
}

function log2nl {
  log $@
  printf "\n"; printf "\n"
}
