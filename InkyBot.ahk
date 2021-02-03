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

/*


*/
; ======================User Config==============================
;RaidTier = 7
;AutoUse = true
;Experimental


;username = 
;password = 
AutoLogin = false

;=======================Init=====================================
Run https://www.kongregate.com/games/juppiomenz/bit-heroes
Init:
loop, 11
{
Sleep 800
;Checking for login
Imagesearch UnityLoadingX,UnityLoadingY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueUnityLoading.png
sleep 20
If (errorlevel = 0)
	{
Goto GameStartCheck
	}
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
Msgbox this should not display
;
Login:
If (%AutoLogin% = true) ;THIS FUNCTION IS NOT FINISHED YET, its close!
{
sleep 3000
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
;Checking to see if you loaded into the game by looking for the daily login reward or the close button on the news window.
Loop, 22
{
sleep, 3020
;need to change over from current close.png
ImageSearch GameCheckX,GameCheckY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,CueClose.png
	If (errorlevel = 0) {
mouseclick,left,%GameCheckX%,%GameCheckY%,1,12
disconnected = false
goto Main
	}
ImageSearch,%claimX%,%claimY%,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueClaimDaily.png
      If (errorlevel = 0) {
mouseclick,left,%claimx%,%claimy%,1,12
Disconnected = false
Goto Main
	}
}
;disconnect failsafe in case logs in to kong but doesnt make it to the news or daily reward screen for cues.
ImageSearch ReconnectX,ReconnectY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueReconnect.png
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
AutoReconnect:
	ImageSearch ReconnectX,ReconnectY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueReconnect.png
	IF (errorlevel = 0) 
	{
	disconnected = true
	MouseClick,left,%ReconnectX%,%ReconnectY%,1,12
	goto GameStartCheck
	}
CheckForIdle:
	ImageSearch IdleX,IdleY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueIdle.png
	IF (errorlevel = 0) 
	{
	MouseClick,left,%IdleX%,%IdleY%,1,12
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
;goto queueTG ;QueueTG code needs to determine/differentiate whether the current event is trials or gauntlet. 
	}

Sleep 18000
}
Return
;==================Raid start script=============================
Queueraids:
;RaidTier difficulty NEEDS to be defined in the config portion or this script will NOT know which raid to run :(
ImageSearch RaidButtonX,RaidButtonY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueRaidbutton.png
;COMMENTED BECAUSE IT WILL REPORT MISSING SQUIGGLE BRACKET SINCE ITS WIP If (errorlevel = 0) { ;
mouseclick,left,%RaidButtonX%,%RaidButtonY%,1,12
Sleep 3000
;Following line SHOULD be ImageSearch RaidTierX,RaidTierY,0,0,%A_ScreenWidth%,%A_ScreenHeight%,cueRaidT%RaidTier%.png



pause::
{
Pause
}

;===Debug for dumb bois
^r::reload



!d::
Msgbox Testing active
sleep 100
If (r = 0) {
msgbox Checked raids and you are out of shards!
}
return



