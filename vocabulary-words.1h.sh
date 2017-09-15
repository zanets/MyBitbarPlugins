#!/bin/bash

# <bitbar.title>vocabulary-words</bitbar.title>
# <bitbar.author>tsmh (darg20127@gmail.com)</bitbar.author>
# <bitbar.author.github>tsmh</bitbar.author.github>
# <bitbar.desc>Help you to memorize vocabulary words.</bitbar.desc>
# <bitbar.version>1.0</bitbar.version>

DIR="$HOME/.Bitbar/vocabulary-words"
LATEST_REFRESH_FILE="${DIR}/latest-refresh"
DICTIONARY_FILE="${DIR}/dictionary"
LIST_FILE="${DIR}/list"
CURRENT_TIME=$(date +%s)
PERIOD=$((24 * 60 * 60)) # 24 hours in seconds
MAX_WORDS=10

mkdir -p "$DIR/" 

echo '📗'
echo '---'

update_refresh () {
    echo ${CURRENT_TIME} > ${LATEST_REFRESH_FILE}
}

refresh () {
    [[ -e ${LIST_FILE} ]] && > ${LIST_FILE}

    if [[ -e ${DICTIONARY_FILE} ]]; then
        # get random words
        DICT_SIZE=$(wc -l < ${DICTIONARY_FILE})
        for i in $(seq 1 $MAX_WORDS); do 
            LINETH=$((1 + $RANDOM % $DICT_SIZE))
            sed -n ${LINETH}p ${DICTIONARY_FILE} >> ${LIST_FILE}
        done
    else
        echo 'Dictionary has not been created.'
    fi

    update_refresh
}

if [[ $1 = "force-refresh" ]]; then
    refresh
    exit
fi

if [[ -e $LATEST_REFRESH_FILE ]]; then
    latest_refresh="$(< ${LATEST_REFRESH_FILE})"
    if (($CURRENT_TIME - $latest_refresh >= $PERIOD)); then
        refresh
    fi
else 
    refresh
fi

while read line; do
    en=$(echo "${line}" | cut -d'|' -f1)
    ch=$(echo "${line}" | cut -d'|' -f2)
    echo "${en}"
    echo "-- ${ch} | color=deepskyblue"
done < ${LIST_FILE}

latest_refresh="$(< ${LATEST_REFRESH_FILE})"
LATEST_REFRESH_DATE=$(date -r ${latest_refresh} +"%Y/%m/%d %H:%M:%S")
echo '---'
echo "Refreshed at ${LATEST_REFRESH_DATE}"
echo "Force refresh | color=green param1=force-refresh refresh=true terminal=false bash='$0'"