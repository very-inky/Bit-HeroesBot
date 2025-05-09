#SingleInstance, Force
#Persistent
SetBatchLines, -1

; --- Constants for Base Capture Settings ---
BasePattern_ScreenWidth_Physical := 3840
BasePattern_ScreenHeight_Physical := 2160
BasePattern_WindowsScaling_Percent := 150
BasePattern_BrowserZoom_Percent := 150

; --- GUI for User Input ---
Gui, Add, Text, xm ym w300, --- Base Pattern Capture Settings ---
Gui, Add, Text, xm+10, (These are fixed based on how your patterns were made)
Gui, Add, Text, xm, Base Screen Width (Physical):
Gui, Add, Edit, x+10 yp-3 w80 vBasePatternScreenWidth_Physical ReadOnly, %BasePattern_ScreenWidth_Physical%
Gui, Add, Text, xm, Base Screen Height (Physical):
Gui, Add, Edit, x+10 yp-3 w80 vBasePatternScreenHeight_Physical ReadOnly, %BasePattern_ScreenHeight_Physical%
Gui, Add, Text, xm, % "Base Windows Scaling (%):" ; <-- Corrected
Gui, Add, Edit, x+10 yp-3 w80 vBasePatternWindowsScaling_Percent ReadOnly, %BasePattern_WindowsScaling_Percent%
Gui, Add, Text, xm, % "Base Browser/App Zoom (%):" ; <-- Corrected
Gui, Add, Edit, x+10 yp-3 w80 vBasePatternBrowserZoom_Percent ReadOnly, %BasePattern_BrowserZoom_Percent%

Gui, Add, Text, xm y+20 w300, --- Desired Target Settings ---
Gui, Add, Text, xm+10, (Enter the settings you want to run the bot with)
Gui, Add, Text, xm, Target Screen Width (Physical):
Gui, Add, Edit, x+10 yp-3 w80 vTargetScreenWidth_Physical, %A_ScreenWidth%
Gui, Add, Text, xm, Target Screen Height (Physical):
Gui, Add, Edit, x+10 yp-3 w80 vTargetScreenHeight_Physical, %A_ScreenHeight%
Gui, Add, Text, xm, % "Target Windows Scaling (%):" ; <-- Corrected
Gui, Add, Edit, x+10 yp-3 w80 vTargetWindowsScaling_Percent, %BasePattern_WindowsScaling_Percent%
Gui, Add, Text, xm, % "Target Browser/App Zoom (%):" ; <-- Corrected
Gui, Add, Edit, x+10 yp-3 w80 vTargetBrowserZoom_Percent, 100

Gui, Add, Button, xm y+20 w150 gCalculateZoom, Calculate FindText Zoom
Gui, Add, Text, xm y+10, Recommended FindText zoomW:
Gui, Add, Edit, x+10 yp-3 w80 vResultZoomW ReadOnly
Gui, Add, Text, xm, Recommended FindText zoomH:
Gui, Add, Edit, x+10 yp-3 w80 vResultZoomH ReadOnly

Gui, Show, , FindText Zoom Calculator
Return

GuiClose:
ExitApp

CalculateZoom:
    Gui, Submit, NoHide

    ; --- Convert percentages to factors ---
    BaseWinScaleFactor := BasePatternWindowsScaling_Percent / 100
    BaseBrowserFactor := BasePatternBrowserZoom_Percent / 100

    TargetWinScaleFactor := TargetWindowsScaling_Percent / 100
    TargetBrowserFactor := TargetBrowserZoom_Percent / 100

    ; --- Calculate the zoom factor for FindText ---
    TotalScale_Base := BaseWinScaleFactor * BaseBrowserFactor
    TotalScale_Target := TargetWinScaleFactor * TargetBrowserFactor

    CalculatedZoomW := TotalScale_Target / TotalScale_Base
    CalculatedZoomH := TotalScale_Target / TotalScale_Base

    GuiControl,, ResultZoomW, % Round(CalculatedZoomW, 3)
    GuiControl,, ResultZoomH, % Round(CalculatedZoomH, 3)

    MsgBox, Calculated Zoom Factors:`nZoomW: %CalculatedZoomW%`nZoomH: %CalculatedZoomH%`n`nNote: This assumes the application's content scales directly with browser/app zoom and Windows scaling. If the application also scales its UI based on the absolute physical resolution change in a different way, further adjustments might be needed.
Return