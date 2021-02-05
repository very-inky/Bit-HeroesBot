# Bit-HeroesBot
Scripting meant to automate the Unity version of Bit Heroes. To replace ilpersi's now non-functional Java based BHBot. The script uses a highly reliable image to text function to retrieve data on screen and act according to that. The script was reworked from scratch, no longer using AHK's native ImageSearch or PixelGetColor commands because they were unreliable. 

Tested: 
based off a user variable at the start of the script, the 'bot' can  automatically open the raid menu and properly select any tier and any of the 3 difficulty for raids, up to and including Raid7 (Gorbon's Rockin' Ruckus).
The bot will automatically detect when it is out of shards and can no longer run any more raids, and will disable checking raids until other tasks have been completed.
Raid selector support is believed to be good!


TODO: There is no functionality yet after the raid has been initiated or canceled. need to add disconnect and "dialogue" checks in the RaidRunning label of the script. So if you get disconnected mid game the bot can account for that, or if you encounter an enemy that has dialogue like a raid boss or legendary raid familiar, that the bot doesn't just hang waiting for the dialogue to go away. Then will add loop functionality since selector is "complete'.
