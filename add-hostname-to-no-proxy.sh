#!/bin/bash

function list_add_unique {
    echo -n "$*" | tr ' ' ',' | awk -v RS=, '!seen[$0]++{print $0}' | paste -s -d,
}

host="$(hostname),$(hostname -I | cut -d' ' -f1)"

for file in /etc/environment /etc/profile.d/proxy.sh; do
    hosts=$(sed -ne 's/.*no_proxy="\?\([^"]\+\)"\?/\1/p' $file)
    sed -i "/no_proxy=/{h;s/=.*/=\"$(list_add_unique $host $hosts)\"/};\${x;/^\$/{s//no_proxy=\"$host\"/;H};x}" $file
    hosts=$(sed -ne 's/.*NO_PROXY="\?\([^"]\+\)"\?/\1/p' $file)
    sed -i "/NO_PROXY=/{h;s/=.*/=\"$(list_add_unique $host $hosts)\"/};\${x;/^\$/{s//NO_PROXY=\"$host\"/;H};x}" $file
done
