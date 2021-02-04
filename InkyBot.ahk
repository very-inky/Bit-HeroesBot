#NoEnv
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%\cues  ; Ensures a consistent starting directory.
; ======================Initial variables==========================
r=0
d=0
wb=0
tg=0
p=0
; ======================Setting timers===========================




; ======================User Config==============================
RaidTier = 3
RaidDifficulty = 3
;AutoUse = true
;Experimental


;username = 
;password = 
AutoLogin = false
/*
*/
;=======================Init=====================================
Run https://www.kongregate.com/games/juppiomenz/bit-heroes
Init:
loop
{
;Checking for login
ImageSearch UnityLoadingX,UnityLoadingY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueUnityLoading.png
sleep 20
If (errorlevel = 0)
	{
Goto GameStartCheck
	}
}
/*
Imagesearch LoggedOutX,LoggedOutY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueKongloggedout.png
sleep 20
If (errorlevel = 0)
	{
goto login
	}
Imagesearch LoggedOutX,LoggedOutY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueKongloggedout1.png
sleep 20
If (errorlevel = 0)
	{
goto login
	}
}
Comment block duct tape, if you remove this the script will not make it to GameStartCheck =(
*/
Msgbox this should not display
;
Login:
If (%AutoLogin% = true) ;THIS FUNCTION IS NOT FINISHED YET, its close!
{
sleep, 3000
ImageSearch AutoLoginX,AutoLoginY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueKongloggedout1.png ;Uhhhhh
	if (errorlevel = 0)
	{
	goto LoginMatched
	}
	Else goto Login
LoginMatched:
sleep 3000
send %username%
sleep 5
send {tab}
sleep 5
sendraw %password%
send {enter}
Msgbox Debug pause
goto Init
}
else
{
msgbox Please log in and restart script.
exitapp
}


GameStartCheck:
Msgbox made it to gamestart check
;Checking to see if you loaded into the game by looking for the daily login reward or the close button on the news window.
Loop
{
ImageSearch GameCheckX,GameCheckY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,CueClose.png
sleep 80
	If (errorlevel = 0) 
	{
mouseclick,left,%GameCheckX%,%GameCheckY%,1,12
disconnected = false
goto Main
	}
ImageSearch,claimX,claimY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueClaimDaily.png
sleep 80
    If (errorlevel = 0)
	{
mouseclick,left,%claimX%,%claimY%,1,12
Disconnected = false
Goto Main
	}
}
;disconnect failsafe in case logs in to kong but doesnt make it to the news or daily reward screen for cues.
ImageSearch ReconnectX,ReconnectY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueReconnect.png
sleep 80
	IF (errorlevel = 0) {
	disconnected = true
	MouseClick,left,%ReconnectX%,%ReconnectY%,1,12
	sleep 200
	goto GameStartCheck
	}
	Else
	{
Msgbox Cant confirm game is running. Closing script.
Exitapp
	}

;Main Script Loop, will start HERE, Dont get confused, it will run the reconnect check, the idle check, then will carry on to Main variable checks.
Main:
Loop
{
AutoReconnect: ;redundant Autoreconnect and idle checks, who cares
	ImageSearch ReconnectX,ReconnectY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueReconnect.png
	sleep 80
	IF (errorlevel = 0) 
	{
	disconnected = true
	MouseClick,left,%ReconnectX%,%ReconnectY%,1,12
	goto GameStartCheck
	}
CheckForIdle:
	ImageSearch IdleX,IdleY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueIdle.png
	sleep 80
	IF (errorlevel = 0) 
	{
	MouseClick,left,%IdleX%,%IdleY%,1,12
	}
CloseFishingBait:
Sleep 1000
	ImageSearch RedCloseX,RedCloseY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueXclose.png
	sleep 80
	If (errorlevel = 0)
	{
	MouseClick,left,%RedCloseX%,%RedCloseY%,1,12
	}
;================================================================
;Main:
	If (r = 0)
	{
goto queueraids
	}
	If (p = 0)
	{
;goto queuepvp
	}
If (tg = 0)
	{
;goto queueTG ;this code needs to determine/differentiate whether the current event is trials or gauntlet. 
	}

Sleep 18000
}

;==================Raid start script=============================
Queueraids:
;RaidTier difficulty NEEDS to be defined in the config portion or this script will NOT know which raid to run :(
;Selecting raid from the screen
ImageSearch RaidButtonX,RaidButtonY,150,150,%A_ScreenWidth%,%A_ScreenHeight%,cueRaidButton.bmp
sleep 120
	If (errorlevel = 0)
	{
	mouseclick,left,%RaidButtonX%,%RaidButtonY%,1,12
	sleep 400
	goto RaidSelector
	}
		Else If (errorlevel = 1)
		{
		goto main
		}
;Figuring out which raid is on screen
RaidSelector:
sleep 100
	ImageSearch WhichRaidX,WhichRaidY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueRaidT3.png
	sleep 800
If (errorlevel = 0)
{
msgbox CORRECT RAID FOUND! HOOORAYYYY;Raid was found, starting difficulty and team selection part here
}
If (errorlevel = 1) ;This portion is if the users RaidTier variable did not correspond with the raid that is displayed when Raid menu is opened, just means we need to search until we find that one!
{
	msgbox Trying selector to find raid .%raidtier%.
	ImageSearch RaidMoveX,RaidMoveY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueRaidMoveR.png
	sleep 80
	mouseclick,left,%RaidMoveX%,%RaidMoveY%,1,12
	sleep 900
	goto RaidSelector
}
Sleep 3000


pause::
{
Pause
}

;===Debug for dumb bois




!d::
Msgbox Testing active
sleep 100
If (r = 0) {
msgbox Checked raids and you are out of shards!
}
return



