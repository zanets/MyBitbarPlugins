#!/bin/bash

# <bitbar.title>vocabulary-words</bitbar.title>
# <bitbar.author>tsmh (darg20127@gmail.com)</bitbar.author>
# <bitbar.author.github>tsmh</bitbar.author.github>
# <bitbar.desc>Help you to memorize vocabulary words.</bitbar.desc>
# <bitbar.version>1.0</bitbar.version>

APPDATA_DIR="$HOME/.bitbar/appdata/vocabulary-words"
LATEST_REFRESH_FILE="$APPDATA_DIR/latest-refresh"
DICTIONARY_FILE="$APPDATA_DIR/dictionary"
LIST_FILE="$APPDATA_DIR/list"
CURRENT_TIME=$(date +%s)
PERIOD=$((24 * 60 * 60)) # 24 hours in seconds
MAX_WORDS=10

mkdir -p "$APPDATA_DIR/" 

echo '📗'
echo '---'

update_refresh () {
    echo $CURRENT_TIME > $LATEST_REFRESH_FILE
}

refresh () {
    [[ -e $LIST_FILE ]] && > $LIST_FILE

    if [[ -e $DICTIONARY_FILE ]]; then
        # get random words
        DICT_SIZE=$(wc -l < ${DICTIONARY_FILE})
        for i in $(seq 1 $MAX_WORDS); do 
            LINETH=$((1 + $RANDOM % $DICT_SIZE))
            sed -n ${LINETH}p $DICTIONARY_FILE >> $LIST_FILE
        done
    else
        echo 'Dictionary has not been created.'
    fi

    update_refresh
}

case "$1" in
    "force-refresh")  
        refresh
        exit
    ;;
    "copy") 
        echo "$2" | pbcopy
        exit
    ;;
esac

if [[ -e $LATEST_REFRESH_FILE ]]; then
    latest_refresh="$(< $LATEST_REFRESH_FILE)"
    if (($CURRENT_TIME - $latest_refresh >= $PERIOD)); then
        refresh
    fi
else 
    refresh
fi

while read line; do
    en=$(echo "$line" | cut -d'-' -f1)
    ch=$(echo "$line" | cut -d'-' -f2)
    echo "$en | param1=copy param2=$en refresh=false terminal=false bash='$0'"
    echo "-- $ch | color=deepskyblue"
done < $LIST_FILE

latest_refresh="$(< $LATEST_REFRESH_FILE)"
LATEST_REFRESH_DATE=$(date -r $latest_refresh +"%Y/%m/%d %H:%M:%S")
echo '---'
echo "Refreshed at $LATEST_REFRESH_DATE"
echo "Force refresh | color=green param1=force-refresh refresh=true terminal=false bash='$0'"
