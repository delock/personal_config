#!/bin/sh

# Configure your favorite diff program here.
DIFF="screen /usr/bin/vimdiff"

# Subversion provides the paths we need as the sixth and seventh
# parameters.
MINE=${9}
OLD=${10}
NEW=${11}

# Call the diff command (change the following line to make sense for
# your merge program).
$DIFF $MINE $NEW $OLD >/dev/null

# Return an errorcode of 0 if no differences were detected, 1 if some were.
# Any other errorcode will be treated as fatal.

cat ${9}
