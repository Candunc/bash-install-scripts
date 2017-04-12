# luainstall

After spinning up multiple Ubuntu VMs for various side projects, I realized I would like a [~~one line~~](https://www.seancassidy.me/dont-pipe-to-your-shell.html) command you can paste into any terminal.

This _should_ automagically install lua5.3 and the latest luarocks as of publishing (luarocks 2.4.2)

```bash
    wget https://raw.githubusercontent.com/Candunc/luainstall/master/install.sh
    if [ "$(sha512sum install.sh | cut -d' ' -f1)" != "d6c463daba8489defd639bea7c1a12023205e8120107a24bb3729d2cb61e3a02175d733d2a3043010305df3b4b79c7abb3e144c29d3ff2835e138501c0e5a0b3" ]; then
        echo "Error validating code. Run at your own risk!"
    else
        sudo bash install.sh
    fi
```