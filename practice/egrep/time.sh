#!/usr/bin/env sh

function hour12 {
echo $1 | egrep '((0[0-9])|(1[0-2])):(([0-5][0-9])|(60)):(([0-5][0-9])|(60))'
}


# 12-hour time
# Should match
hour12 '12:34:56'

# Should match
hour12 '00:00:60'


# Shouldn't match
hour12 '23:45:67'

# Shouldn't match
hour12 '12:67:34'

# Shouldn't match
hour12 '12:34:67'

echo


function hour24 {
  echo $1 | egrep '(([0-1][0-9])|(2[0-3])):(([0-5][0-9])|(60)):(([0-5][0-9])|(60))'
}

# 24-hour time

# Should match
hour24 '12:34:56'

# Should match
hour24 '23:56:56'

# Should match
hour24 '00:00:60'


# Shouldn't match
hour24 '24:56:56'

# Shouldn't match
hour24 '23:67:45'

# Shouldn't match
hour24 '23:45:67'



