#!/bin/bash
#Designed to run on Ubuntu 16.10 Server
#Child of rt-downloader
if [ "$EUID" -ne 0 ]; then 
	echo "Please run as root"
	exit 1
fi

verifyChecksum() {
	#Expects two arguments, $1 being the filename and $2 being the hash.
	filehash=$(sha512sum $1 | cut -d' ' -f1)
	if [ "$filehash" == "$2" ]; then
		return 0
	else
		return 1
	fi
}

apt-get -y install unzip make gcc git libreadline-dev libssl-dev

#Check if lua is installed
mkdir /tmp/lua
type lua >/dev/null 2>&1 || {
	cd /tmp/lua
	wget http://www.lua.org/ftp/lua-5.3.3.tar.gz
	verifyChecksum 'lua-5.3.3.tar.gz' '7b8122ed48ea2a9faa47d1b69b4a5b1523bb7be67e78f252bb4339bf75e957a88c5405156e22b4b63ccf607a5407bf017a4cee1ce12b1aa5262047655960a3cc'
	if [ $? == 1 ]; then
		echo "Checksum of lua-5.3.3.tar.gz failed. Exiting..."
		exit 1
	fi

	tar -xzf lua-5.3.3.tar.gz
	cd /tmp/lua/lua-5.3.3
	make linux

	#Test if the binary is built correctly
	if [ "$(src/lua -v)" != "Lua 5.3.3  Copyright (C) 1994-2016 Lua.org, PUC-Rio" ]; then
		echo "Something went wrong when building lua. Please submit an error report:"
		echo "https://github.com/Candunc/luainstall/issues"
		exit 1
	fi

	#Done with lua, install and proceed to luarocks
	echo "Lua 5.3.3 successfully built!"
	make linux install
}

type luarocks >/dev/null 2>&1 || {
	cd /tmp/lua

	wget http://luarocks.github.io/luarocks/releases/luarocks-2.4.2.tar.gz
	verifyChecksum 'luarocks-2.4.2.tar.gz' '30e3b3fb338387412f406c415af49d3624f4dfc05ac5f245185127a0288248ccfae924e7bbdd5b68fef00524c7cc70d9f632ae00f4c696bdf0582e71e8945bc4'

	tar -xzf luarocks-2.4.2.tar.gz
	cd luarocks-2.4.2
	/tmp/lua/luarocks-2.4.2/configure
	make build
	cd /tmp/lua/luarocks-2.4.2/src

	#Just see if the binary runs before installing it.
	if [ "$(./bin/luarocks list | sha512sum)" != "c5a4700eb2f97b60ac50854d4cb8fbe2c290a099954b6cfacd2989ac9157e8fc0ffb9fec7ab05ebbf346ac8f850cde6d99baca5c4d8d72960df2e81c0b868965  -" ]; then
		echo "Something went wrong when building luarocks. Please submit an error report:"
		echo "https://github.com/Candunc/luainstall/issues"
		exit 1
	fi

	cd /tmp/lua/luarocks-2.4.2/

	make install
}

#And clean up our mess
cd ~
rm -r /tmp/lua
