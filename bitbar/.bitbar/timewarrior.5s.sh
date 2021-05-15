#!/bin/bash

# <bitbar.title>timewarrior helper</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Nick Kezhaya</bitbar.author>
# <bitbar.author.github>whitepaperclip</bitbar.author.github>
# <bitbar.desc>Shows the current timewarrior status</bitbar.desc>
# <bitbar.dependencies>timewarrior</bitbar.dependencies>

export PATH=/usr/local/bin:$PATH

if [[ "$1" = "stop" ]]; then
  timew stop
elif [[ "$1" = "cont1" ]]; then
  timew continue @1
elif [[ "$1" = "cont2" ]]; then
  timew continue @2
elif [[ "$1" = "bscall" ]]; then
  timew track BS Call
fi

if [[ $(timew | head -n1) =~ 'no active time tracking' ]]; then
  echo "00:00:00"
else
  title=$(timew | head -n1 | sed 's/Tracking //')
  echo $title
fi

echo "---"
echo "Continue @1 | bash='$0' param1=cont1 terminal=false refresh=true"
echo "Continue @2 | bash='$0' param1=cont2 terminal=false refresh=true"
echo "BS Call | bash='$0' param1=bscall terminal=false refresh=true"
echo "Stop timewarrior | bash='$0' param1=stop terminal=false refresh=true"
