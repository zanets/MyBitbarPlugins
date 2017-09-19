#!/bin/bash

if [ "$1" = 'activity_monitor' ]; then
    osascript << END
    tell application "Activity Monitor"
        reopen
        activate
    end tell
END
    exit 0
fi

OLDIFS=$IFS
width=25

IFS=$'\n'
topdata=($(top -F -R -l2 -o cpu -n 5 -s 2 -stats pid,command,cpu,mem))
nlines=${#topdata[@]}
    
IFS=$OLDIFS
for ((i = nlines / 2; i < nlines; i++)); do
    line=(${topdata[$i]})
    word=${line[0]}
    if [ "$word" = Load ]; then
        loadstr=${line[*]}
    elif [ "$word" = CPU ]; then
        cpustr=${line[*]}
        cpu_user=${line[2]}
        cpu_sys=${line[4]}
        cpu_idle=${line[6]}
    elif [ "$word" = PhysMem: ]; then
        memused=${line[1]}
        memunused=${line[5]}
    elif [ "$word" = Networks: ]; then
        networkin=${line[2]}
        networkout=${line[4]}
    elif [ "$word" = PID ]; then
        top5=("${topdata[@]:$i}")
    fi
done
IFS=$'\n'

idle=$( echo $cpu_idle | grep -o -E '[0-9]{1,2}.[0-9]{1,2}')
usage=$( echo "100 - $idle" | bc )

if [[ $(echo "$usage < 50" | bc) == 1 ]]; then
    color="green"
elif [[ $(echo "$usage < 80" | bc) == 1 ]]; then
    color="yellow"
else
    color="red"
fi

TEMPERATURE=$(/usr/local/bin/smc -k TC0D -r | sed 's/.*bytes \(.*\))/\1/' |sed 's/\([0-9a-fA-F]*\)/0x\1/g' | perl -ne 'chomp; ($low,$high) = split(/ /); print (((hex($low)*256)+hex($high))/4/64); print "\n";')
TEMP_INTEGER=${TEMPERATURE%.*}

echo "$usage% $TEMP_INTEGER°c | color=$color"
echo "---"
echo "CPU: $cpu_user user, $cpu_sys sys, $cpu_idle idle | refresh=true"
echo "$loadstr | refresh=true"
echo "Memory: $memused / $memunused | refresh=true"
echo "Network: $networkin, $networkout | refresh=true"
echo "---"
IFS=$OLDIFS
top5=("${top5[@]/%/| font=Menlo}")
IFS=$'\n'
echo "${top5[*]}"
IFS=$OLDIFS
echo "---"
echo "Open Activity Monitor | bash='$0' param1=activity_monitor terminal=false"