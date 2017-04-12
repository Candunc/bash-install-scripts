#!/bin/bash
#Todo: Add support for (config?) to update on crash (a la patching Bitcoin Unlimited vulns)
if [[ ! `pidof -s bitcoind` ]]; then
        $HOME/start.sh >/dev/null 2>&1
fi
exit 0
