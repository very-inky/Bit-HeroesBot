# Bit-HeroesBot
Scripting meant to automate the Unity version of Bit Heroes. To replace ilpersi's now non-functional Java based BHBot. The script uses a highly reliable image to text function to retrieve data on screen and act according to that. The script was reworked from scratch, no longer using AHK's native ImageSearch or PixelGetColor commands because they were unreliable. 

Tested: 
based off a user variable at the start of the script, the 'bot' can  automatically open the raid menu and properly select any tier and any of the 3 difficulty for raids, up to and including Raid7 (Gorbon's Rockin' Ruckus).
The bot will automatically detect when it is out of shards and can no longer run any more raids, and will disable checking raids until other tasks have been completed.
Raid selector support is believed to be good!


TODO:Raid main loop needs testing, and need to add looped reconnect checks.
