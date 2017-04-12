#!/bin/which bash
if [ "$EUID" -ne 0 ];  then
	echo "Please run as root"
	exit
fi

command -v netselect-apt >/dev/null 2>&1 || { apt-get -y install netselect-apt; }
echo "Searching for fastest mirrors... this may take a while."

netselect-apt >/tmp/mirrors.txt 2>/dev/null
NUM1=$((2 + RANDOM % 10)) #Pick a random mirror from the fastest 10
NUM2=$((2 + RANDOM % 10))
while [ $NUM2 -eq $NUM1 ] #Ensure the numbers are unique
do
	NUM2=$((2 + RANDOM % 10))
done

mirror1=$(sed "${NUM}q;d" /tmp/mirrors.txt | tr -d '[:space:]')
mirror2=$(sed "${NUM}q;d" /tmp/mirrors.txt | tr -d '[:space:]')
rm /tmp/mirrors.txt sources.list

for f in experimental.list stable.list testing.list unstable.list
do
	sed -i -e "s|MIRROR1|${mirror1}|g" "sources.list.d/${f}"
	sed -i -e "s|MIRROR2|${mirror2}|g" "sources.list.d/${f}"
done

mv preferences.d/* /etc/apt/preferences.d/
mv sources.list.d/* /etc/apt/sources.list.d/

echo "Should be complete! Run apt-get update and look for the following mirrors:"
echo $mirror1
echo $mirror2