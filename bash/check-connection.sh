#!/bin/bash

# Author: /u/kevors
# Reddit: https://www.reddit.com/r/bash/comments/o8go3x/:/h359gkt/
# Permalink: https://github.com/slowpeek/my-reddit/blob/master/bash/check-connection.sh

t_rst=$(tput sgr0)
t_info=$(tput setaf 2)
t_warn=$(tput setaf 3)
t_err=$(tput setaf 1)
t_crdl=$(tput -S <<< $'cr\ndl1')

ghome=google.com
gdns=8.8.8.8

read -r gway gifc < <(ip r s default | awk '{ print $3, $5; exit }')

readarray -td@ text <<EOF

You are ${t_info}connected${t_rst} to those your internets via interface ${gifc}.

@

Your ${t_warn}DNS server(s)${t_rst} does not seem to be responding.
/etc/resolv.conf file might be of interest to you.

@

Problem seems to be with the ${t_warn}ISP${t_rst}. Contact the ISP.

@

${t_err}Can't connect${t_rst} to either your router or your modem.

- Make sure the PC's network is properly configured.
- Check if the router or modem is switched on.
- Check if the network cable is correctly attached.
- In case of wireless router check the signal level.

EOF

ping_test () {
    echo -n ping "$1" ...

    local st
    ping -q -w1 -c1 "$1" &>/dev/null
    st=$?

    echo -n "$t_crdl"

    return "$st"
}

say () {
    local s=${text[$1]}

    s=${s#${s%%[![:space:]]*}}
    s=${s%${s##*[![:space:]]}}

    printf '\n%s\n\n' "$s"
}

st=0 n=0
for host in ghome gdns gway; do
    if ping_test "${!host}"; then
        say "$n"
        exit "$st"
    fi

    st=1
    ((++n))
done

say "$n"
exit 1
