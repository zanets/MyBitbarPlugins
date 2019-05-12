#!/bin/bash

# <bitbar.title>Clipboard</bitbar.title>
# <bitbar.author>tsmh (darg20127@gmail.com)</bitbar.author>
# <bitbar.author.github>tsmh</bitbar.author.github>
# <bitbar.desc>Track up to 50 clipboard history or save as snippet.</bitbar.desc>
# <bitbar.version>1.0</bitbar.version>

# SETTINGS

HIST_DIR="/tmp/bitbar/2_clipboard/history"
HIST_MAX=50

SNIP_DIR="$HOME/.bitbar/appdata/2_clipboard/snippets"
SNIP_MAX=50

LENGTH=20

# ENVIRONMENT

export LANG="${LANG:-en_US.UTF-8}"
mkdir -p "$SNIP_DIR" &> /dev/null
mkdir -p "$HIST_DIR" &> /dev/null
[ -f "$SNIP_DIR/index" ] || echo -n 0 > "$SNIP_DIR/index"
[ -f "$HIST_DIR/index" ] || echo -n 0 > "$HIST_DIR/index"

# HELPER

notify () {
	osascript -e "display notification \"$1\" with title \"BitBar Clipboard\"" &> /dev/null
}

# 1: location
getIDX () {
	IDXF="$1/index"
	if [ -f "$IDXF" ]; then
		echo "$(< $IDXF)"
	else
		notify "Cannot found index file at $1"
		exit
	fi
}

# 1: location, 2: content, 3: maxi, 4: circle mode
addItem () {
	IDX=$(getIDX $1)
	newIDX="$((IDX + 1))"
	MAXIDX=$3

	if [ $newIDX -gt $MAXIDX ]; then
		if [ $4 -eq 0 ]; then
			notify "Exceed $MAXIDX items. Aborting." 
			return
		else
			newIDX=1
		fi
	fi

	echo -n "$2" > "$1/item-$newIDX.pb"
	echo -n "$newIDX" > "$1/index"
}

# 1: location, 2: max
showItems () {
	# the location of first one is recorded at index file
	IDX=$(getIDX $1)
	MAXIDX=$2
	for i in $(seq 1 $MAXIDX); do
		
		file="$1/item-$IDX.pb"
		if [[ -e $file ]]; then
			content="$(< $file)"
		
			# @addItem
			[[ $(( i % 10 )) == 1 ]] && echo "$i - $((i+9))"
		
			# @addItem
			echo "-- $i "$content" | param1=copy param2=$file length=$LENGTH terminal=false bash='$0'"
			
			IDX=$((IDX - 1))
			[ $IDX -lt 1 ] && IDX=$MAXIDX  
		else
			return
		fi
	done
}

showCurrentClipboard () {
	CANDI="$(pbpaste)"
	[[ -z "${CANDI//}" ]] && return
	
	# @addItem
	echo ""$CANDI" | param1=add-snip length=$LENGTH terminal=false bash='$0' refresh=true"

	# if not same with last history, add to history
	IDX=$(getIDX $HIST_DIR)
	echo -n "$CANDI" | diff "$HIST_DIR/item-$IDX.pb" - &> /dev/null
	if [[ $? != 0 ]]; then
		addItem "$HIST_DIR" "$CANDI" "$HIST_MAX" 1  
	fi
}

# HANDLE COMMANDS

case "$1" in
	"copy" )
		[[ -z "${2// }" ]] || pbcopy < "$2"
		exit
		;;
	"clear-hist" )
		pbcopy < /dev/null
		rm -f "$HIST_DIR"/item-*.pb
		exit
		;;
	"clear-snip" )
		rm -f "$SNIP_DIR"/item-*.pb
		exit
		;;
	"add-snip" )
		addItem "$SNIP_DIR" "$(pbpaste)" "$SNIP_MAX" 0
		exit
		;;
esac

# DISPLAY

echo '📋'
echo "---"

# Display Current Clipboard Content
echo "Clipboard | color=deepskyblue"
showCurrentClipboard

# Display History
echo "---"
echo 'History | color=deepskyblue'
showItems "$HIST_DIR" "$HIST_MAX"

# Display Snippets
echo "---"
echo 'Snippets | color=deepskyblue'
showItems "$SNIP_DIR" "$SNIP_MAX"

# Display Commands
echo "---"
# @addItem
echo "Clear History | color=red param1=clear-hist refresh=true terminal=false bash='$0'"
# @addItem
echo "Clear Snippets | color=red param1=clear-snip refresh=true terminal=false bash='$0'"
