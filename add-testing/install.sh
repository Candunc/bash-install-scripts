#!/bin/which bash
if [ "$EUID" -ne 0 ];  then
	echo "Please run as root"
	exit
fi

command -v netselect-apt >/dev/null 2>&1 || { apt-get -y install netselect-apt; }
echo "Searching for fastest mirrors... this may take a while."

netselect-apt >/tmp/mirrors.txt 2>/dev/null
NUM=$((1 + RANDOM % 10 + 1)) #Pick a random mirror from the fastest 10

mirror=$(sed "${NUM}q;d" /tmp/mirrors.txt | tr -d '[:space:]')
rm /tmp/mirrors.txt sources.list

for f in experimental.list security.list stable.list testing.list unstable.list
do
	sed -i -e "s|MIRROR|${mirror}|g" "sources.list.d/${f}"
done

mv preferences.d/* /etc/apt/preferences.d/
mv sources.list.d/* /etc/apt/sources.list.d/

echo "Should be complete! Run apt-get update and look for the following mirror:"
echo $mirror