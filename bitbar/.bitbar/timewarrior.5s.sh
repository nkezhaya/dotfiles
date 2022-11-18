#!/bin/bash

# <bitbar.title>timewarrior helper</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Nick Kezhaya</bitbar.author>
# <bitbar.author.github>whitepaperclip</bitbar.author.github>
# <bitbar.desc>Shows the current timewarrior status</bitbar.desc>
# <bitbar.dependencies>timewarrior</bitbar.dependencies>

export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

if [[ "$1" = "stop" ]]; then
  timew stop
elif [[ "$1" = "bscall" ]]; then
  timew track BS Call
elif [[ $1 = cont* ]]; then
  arg=$1
  taskid=${arg:4}
  timew continue @$taskid
fi

if [[ $(timew | head -n1) =~ 'no active time tracking' ]]; then
  echo "00:00:00"
else
  title=$(timew | head -n1 | sed 's/Tracking //')
  echo $title
fi

echo "---"

while read -r proc; do
  if [ -n "$proc" ]; then
    i=$(echo $proc | grep -o -E '[0-9]+' | head -n1)
    echo "Continue $proc | bash='$0' param1=cont$i terminal=false refresh=true"
  fi
done <<< "$(timew tagsum)"

echo "BS Call | bash='$0' param1=bscall terminal=false refresh=true"
echo "Stop timewarrior | bash='$0' param1=stop terminal=false refresh=true"
