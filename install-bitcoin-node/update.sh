#!/bin/bash
# Tested against Debian Jessie
# Assume build tools are included.

#Changed from $HOME to $HOME as recommended:
#https://superuser.com/a/808591/607043

# http://stackoverflow.com/a/29496982/1687505; http://unix.stackexchange.com/a/93030
CPUTHREADS=$(( $(grep -c   "^processor" /proc/cpuinfo) - 1 ))

if [ ! -d $HOME/.btc_updater ]; then
	mkdir $HOME/.btc_updater
else
	if [ -a $HOME/.btc_updater/last_commit.txt ]; then
		last_commit=$(<$HOME/.btc_updater/last_commit.txt)
	fi
fi

if [ -a $HOME/.btc_updater/running ]; then
	echo "Script already running!"
	exit 1
fi
touch $HOME/.btc_updater/running



cd $HOME/.btc_updater

if [ ! -d btc-source ]; then
	#Todo: Add implementation for Bitcoin Core via flags or config or something like that.
	# git clone https://github.com/bitcoin/bitcoin.git btc-source
	git clone https://github.com/BitcoinUnlimited/BitcoinUnlimited.git btc-source
	cd btc-source
else
	cd btc-source
	git pull
fi

#Again, needs to be changed to support Bitcoin Core.
git checkout release

commit=`git rev-parse HEAD`
if [ "$commit" == "$last_commit" ]; then
	# No new version to build.
	rm $HOME/.btc_updater/running
	bash $HOME/start.sh
	exit 0
fi

make clean
./autogen.sh
./configure --disable-wallet --without-gui --without-miniupnpc
make -j $CPUTHREADS
if [ ! $? -eq 0 ]; then
	echo "Error in building latest release, please try building manually."
	rm $HOME/.btc_updater/running
	exit 1
fi

src/test/test_bitcoin
if [ ! $? -eq 0 ]; then
	echo "Error in running bitcoin tests!"
	rm $HOME/.btc_updater/running
	exit 1
fi

if [ ! -d $HOME/bin/ ]; then
	mkdir $HOME/bin/
else
	if [ -a $HOME/bin/bitcoind ]; then
		rm bitcoind bitcoin-cli bitcoin-tx
	fi
fi

cp src/bitcoind src/bitcoin-cli src/bitcoin-tx $HOME/bin/
echo $commit > $HOME/.btc_updater/last_commit.txt

rm $HOME/.btc_updater/running

# Now that we're done compiling, start up our new node.
bash $HOME/start.sh