# Randomizer!

Garry's Mod gamemode with random weapons

[Click to skip to the install instructions](#Installing)

## What?
Randomizer is a fast-paced PvP deathmatch-type gamemode that revolves around randomized weapons.

## Features?
Randomizer! is configurable with support for a custom weapons pool, including weapons from any other add-ons you have installed. It also provides you with several round types that add a fun twist to the base gamemode (see below)

## Round Types

### Standard
The standard type - each time you spawn, you get a new set of weapons. Get a set amount of kills to win!

### 2 Teams, 4 Teams
The standard type except players are randomly divided into teams - Red, Green, Blue, and Yellow. Help your team reach the set amount of kills to win!

### True Randomizer
Every kill gives you a new set of weapons! Some quick thinking will be required.

### Equalized
Everyone has the same set of weapons! See who can utilize them the best and reach the set amount of kills to win!

### Target
One player is chosen to be the Target, and everyone else must work together to quickly kill them before they win.

### Enabling / Disabling round types
Server hosts are given the freedom to pick any amount of round types to enable - from the full set to a server that only plays a certain round type.

## Configuring the Weapon List
If you want to use your own pool of weapons rather than the default *Half-Life 2* weapons, this section will help you set up your weapons list:

### Managing your weapons list
It's recommended to keep your weapons list in a .txt file for easy access. Please note that if you opt to use a custom list, the HL2 weapons will not be included in the pool by-default

### Adding a weapon
The easiest way to add a weapon is as such:
- Open up sandbox
- Navigate to Spawn menu > Weapons > [category of your desired weapon]
- Pick the weapon you want and right-click it.
- Select `Copy to clipboard`
- Paste the text that was copied into the weapons list.

## Troubleshooting
*Please read if you're having problems with the gamemode*

To start off with the obvious, try disabling any other add-ons you have installed to see if that fixes the error. You may have to disable / uninstall whichever add-on is causing issues. Sorry about that!

### My players aren't properly receiving weapons!
If your players are not receiving weapons, you probably made a mistake in the weapons pool. Try fixing any spelling errors in or removing the weapon's name from the pool and see if that resolves it.

### My kills aren't registering!
This is caused by wrongly configured weapons that register the entity as the killer, rather than the player. If the kill feed for example shows `#ent_[whatever]` instead of a player's name, then a weapon isn't working properly. Unfortunately I don't think there is any way for me to fix this, so consider removing whichever weapon(s) are causing this issue from the pool.

And remember, when in doubt, try to simply restart the server. There was a lot of playtesting involved in the creation of this gamemode, but I can't personally catch everything.

You might also want to submit an issue to help me investigate, I'll need some details of what was happening when the issue occured and a log of the error.

## Installing
Please [download the latest release](https://github.com/axiand/randomizer/releases/latest) (get the .gma file) and place it in your addons folder (this would probably be `C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons` if you intend to host the gamemode on a standard Windows machine)

Once you've done that, restart / fire up Garry's Mod, and you should be set! Make sure to select the gamemode from the bottom-right menu.

## Why not Workshop?
~~Can't upload it there because I'm playing GMod through Family Sharing which makes me unable to post on the workshop, and I don't intend to buy a separate copy just to do so. Valbo pls fixe~~ disregard because this issue has been fixed. Speaking of, you should probably [check out this mod on the workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2915537217)
