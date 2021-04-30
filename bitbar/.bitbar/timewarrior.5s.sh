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
elif [[ "$1" = "continue" ]]; then
  timew continue
fi

if [[ $(timew | head -n1) =~ 'no active time tracking' ]]; then
  echo "00:00:00"
else
  title=$(timew | head -n1 | sed 's/Tracking //')
  echo $title
fi

echo "---"
echo "Continue @1 | bash='$0' param1=continue terminal=false refresh=true"
echo "Stop timewarrior | bash='$0' param1=stop terminal=false refresh=true"
