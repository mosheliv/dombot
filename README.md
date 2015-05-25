# Dombot
Bot for controlling Domoticz using Google Hangouts
Introduction
this is a simple framework for controlling an inquiring domoticz using xmpp chat. I use google hangouts but any other xmpp compatible chat should work fine.
the bot accepts commands and return answers inside the same session. the framework allows you to easily include more commands without modifying any of the framework code.

The formatting abilities of the hangout client leaves much to be desired but it is still readable.

currently the bot comes with 3 commands:
	list - list all devices (or a subset by type) with name, data and idx
	dump - like list but dumps most of the useful fields
	flick - turn a switch on or off by idx
	devices - return list of devices
	nflick - flick device on or off by name
	batteries - list all battery operated devices and their level

# Pre-requisits
1. lua5.1 
2. lua-socket 
3. lua5.1-expat
4. lua-sec

#Installation

lua5.1 and lua socket lib should be installed on the computer. I think they are installed on domoticz by default. If this is not the case let me know and i’ll include more detailed instructions
create a chat account for your automation system. NOTE:NEVER USE YOUR PRIVATE MAIN ACCOUNT! 
after creating the account send message from your account to this account and the other way around. this guarantee that they can talk with each other.
get the files:
the easy way:
just get all the files from whereever i put them (git?)
the harder way
install verse using these instructions: http://www.thiessen.im/2010/10/riddim-a-neat-little-xmpp-bot-written-in-lua/ 
There is no need to finish the install. just stop after squishing verse. copy verse.lua from the top directory and verse/lib/bit.lua into your target bot directory
get the JSON lib from: http://regex.info/blog/lua/json and unpack into your bot directory
get my files from whereever (bot.lua, bot.cfg.example, list.lua, flick.lua)
copy bot.cfg.example to bot.cfg and type in the bot chat credentials (the bot! not yours!). 
run “lua bot.lua”
try it out by sending “x list” (x is the passphrase)

#Adding commands
just copy list or flick and modify them. add the name of your modules to bot.cfg, thats it!

#Credits
1. JSON library by Jeffrey Friedl
2. Special thanks for Matthew Wild for writing Verse and helping me out with starting (and continuing :-) )
