#!/bin/bash

# <bitbar.title>Clipboard</bitbar.title>
# <bitbar.author>tsmh (darg20127@gmail.com)</bitbar.author>
# <bitbar.author.github>tsmh</bitbar.author.github>
# <bitbar.desc>Track up to 50 clipboard history or save as snippet.
# <bitbar.version>1.0</bitbar.version></bitbar.desc>

# Environment
export LANG="${LANG:-en_US.UTF-8}"

HIST_DIR="/tmp/BitBar/Store/History"
HIST_MIN=0
HIST_MAX=49

SNIP_DIR="$HOME/.BitBar/Store/Snippets"
SNIP_MIN=0
SNIP_MAX=49

LENGTH=20

mkdir -p "$SNIP_DIR" &> /dev/null
mkdir -p "$HIST_DIR" &> /dev/null

notify () {
  osascript -e "display notification \"$1\" with title \"BitBar Clipboard\"" &> /dev/null
}

# Copy file content to clipboard
if [[ $1 = "copy" ]]; then
  if [[ -e $2 ]]; then
    pbcopy < "$2"
    notify "Copied to Clipboard."
  fi
  exit
fi

# Delete all history
if [[ $1 = "clear-hist" ]]; then
  pbcopy < /dev/null
  rm -f "$HIST_DIR"/item-*.pb
  notify "Cleared clipboard history."
  exit
fi

# Store snippets
if [[ $1 = "store-snip" ]]; then
  # Find a number which has not been used.
  for i in $(seq $SNIP_MIN $SNIP_MAX); do
    file="$SNIP_DIR/item-$i.pb"
    if [[ ! -e $file ]]; then
      echo "$(pbpaste)" > "$file"
      notify "Snippet stored."
      exit
    fi
  done
  
  # All number has been used.
  notify "Snippets are up to $SNIP_MAX. Store failed."
fi

# Delete all snippets
if [[ $1 = "clear-snip" ]]; then
  rm -f "$SNIP_DIR"/item-*.pb
  notify "Cleared snippets."
  exit
fi

echo '📋'
echo "---"

# Get clipboard content 
cbContent=$(pbpaste)

# Show clipboard content on clipboard section
echo "Clipboard | color=deepskyblue"
if [[ $cbContent != "" ]]; then

  # @addItem
  echo ""$cbContent" | param1=store-snip length=$LENGTH terminal=false bash='$0' refresh=true"

  echo "$cbContent" | diff "$HIST_DIR/item-$HIST_MIN.pb" - &> /dev/null
  if [ "$?" != "0" ]; then
    # Move previous history backwards
    for i in $(seq $HIST_MAX $HIST_MIN); do
      file="$HIST_DIR/item-$i.pb"
      [[ -e $file ]] && cp $file "$HIST_DIR/item-$((i+1)).pb" &> /dev/null
    done
  
    # Store to minimum number
    echo "$cbContent" > "$HIST_DIR/item-$HIST_MIN.pb"
  fi
fi

# Show history section
echo "---"
echo 'History | color=deepskyblue'
for i in $(seq $HIST_MIN $HIST_MAX); do
  file="$HIST_DIR/item-$i.pb"
  if [[ -e $file ]]; then
    content="$(< $file)"
    # @addItem
    [[ $(( i % 10 )) == 0 ]] && echo "$((i+1)) - $((i+10))"
    # @addItem
    echo "-- $((i+1)) "$content" | param1=copy param2=$file length=$LENGTH terminal=false bash='$0'"
  fi
done

# Show snippet section
echo "---"
echo 'Snippets | color=deepskyblue'
for i in $(seq $SNIP_MIN $SNIP_MAX); do
  file="$SNIP_DIR/item-$i.pb"
  if [[ -e $file ]]; then
    content="$(< $file)"
    # @addItem
    [[ $(( i % 10 )) == 0 ]] && echo "$((i+1)) - $((i+10))"
    # @addItem
    echo "-- $((i+1)) "$content" | param1=copy param2=$file length=$LENGTH terminal=false bash='$0'"
  fi
done

echo "---"
# @addItem
echo "Clear all history | color=red param1=clear-hist refresh=true terminal=false bash='$0'"
# @addItem
echo "Clear all snippets | color=red param1=clear-snip refresh=true terminal=false bash='$0'"
