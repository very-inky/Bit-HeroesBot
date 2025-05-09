;resolution and scaling tester
#SingleInstance, Force
#Persistent
SetBatchLines, -1

; --- Ensure FindText.ahk is in the same directory
#Include FindText.ahk


; --- Configuration Variables to Test ---
TestPattern       := "|<>*120$66.zzU000001zzzz0000000zzzy0000000Tzzw0000000Dzzs00000007zzk00000003zzU00000001zz000000000zz03k0003s0zy07w000Ds0Tw07z3zkzs0Dw07zzzzzs0Ds07zzzzzs07s07zzzzzs07k07zzzzzs03k07zzzzzs03k07zzzzzs03U07zzzzzs03U0Dzzzzzw01U0Dzzzzzy01U0Tzzzzzy0100Tzzzzzy0100Tzzzzzz0000zzzzzzz0000zzzzzzz0000zzzzzzz0000zzzzzzz0000zzzzzzz0000zzzzzzz0000zzzzzzz0000Tzzzzzy0000Tzzzzzy0000Tzzzzzy00U0Dzzzzzw01U0Dzzzzzw01U07zzzzzs01U03zzzzzs01k01zzzzzk03k00zzzzz003k00Tzzzy003s703zzzk007s3k07zw0007w1s0Dzw000Dw0s0Dzw000Dy0Q0Dzy000Tz0S0Tzy000zz0DUzzy000zzUDzzzy001zzk7zzzy003zzs3zzzy007zzw0zzzy00Dzzy00Tzy00Tzzz00Tzy00zzzzU0Tzy01zzzzs0Tzy07zzzzw0Tzy0Dzzzzz0Tzy0zzzzzzsTzy7zzzU"
                                             ; Replace with your pattern to test

TestZoomW         := 1.0  ; Zoom factor for width (1.0 = 100% = no zoom)
TestZoomH         := 1.0  ; Zoom factor for height (1.0 = 100% = no zoom)

TestErr1          := 0.09 ; Fault tolerance. Generally 0.0N seems to work best where you only change N
TestErr0          := 0.09 ; same as above

; --- Search Area (0,0,0,0 or blank means full screen) ---
SearchX1          := 0
SearchY1          := 0
SearchX2          := 0
SearchY2          := 0

; --- Hotkey to run the test ---
F1::
    GoSub, TestFindText
return

TestFindText:
    OutputDebug, Starting FindText Test...
    OutputDebug, Pattern: %TestPattern%
    OutputDebug, ZoomW: %TestZoomW%, ZoomH: %TestZoomH%
    OutputDebug, Err1: %TestErr1%, Err0: %TestErr0%

    startTime := A_TickCount
    
    ; Call FindText directly in an If statement
    ; Parameters: OutputX, OutputY, X1, Y1, X2, Y2, err1, err0, Text, ScreenShot, FindAll, JoinText, offsetX, offsetY, dir, zoomW, zoomH
    ; The FindText() function itself (when not assigning to a variable first) returns the array of found objects,
    ; which evaluates to true in a boolean context if matches are found, and 0 (false) if not.
    ; The X and Y coordinates are still populated in FoundX and FoundY.
    if FindText(FoundX, FoundY, SearchX1, SearchY1, SearchX2, SearchY2, TestErr1, TestErr0, TestPattern, 1, 0, 0, 20, 10, 0, TestZoomW, TestZoomH)
    {
        elapsedTime := A_TickCount - startTime
        
        ; To access the details of the found items, you need to get the result object.
        ; FindText() stores the last result in its own internal 'ok' property.
        foundObjectArray := FindText().ok ; Access the array of found objects

        resultMsg := "FindText Test Results:`n"
        resultMsg .= "--------------------------`n"
        resultMsg .= "Pattern Used: " TestPattern "`n"
        resultMsg .= "Zoom W: " TestZoomW ", Zoom H: " TestZoomH "`n"
        resultMsg .= "Error1: " TestErr1 ", Error0: " TestErr0 "`n"
        resultMsg .= "Time Taken: " elapsedTime " ms`n`n"
        resultMsg .= "Status: FOUND!`n"
        resultMsg .= "Found " foundObjectArray.MaxIndex() " match(es).`n"
        resultMsg .= "First match at: X=" . foundObjectArray[1].x . ", Y=" . foundObjectArray[1].y . "`n" ; Or just use FoundX, FoundY for the first match
        resultMsg .= "Comment: " . foundObjectArray[1].id . "`n"
        resultMsg .= "W: " . foundObjectArray[1].3 . ", H: " . foundObjectArray[1].4
        SoundBeep, 750, 300
    }
    else
    {
        elapsedTime := A_TickCount - startTime
        resultMsg := "FindText Test Results:`n"
        resultMsg .= "--------------------------`n"
        resultMsg .= "Pattern Used: " TestPattern "`n"
        resultMsg .= "Zoom W: " TestZoomW ", Zoom H: " TestZoomH "`n"
        resultMsg .= "Error1: " TestErr1 ", Error0: " TestErr0 "`n"
        resultMsg .= "Time Taken: " elapsedTime " ms`n`n"
        resultMsg .= "Status: NOT FOUND."
        SoundBeep, 250, 300
    }

    ToolTip, % resultMsg
    SetTimer, RemoveToolTip, -3000 ; Remove tooltip after 3 seconds
    OutputDebug, % resultMsg
    OutputDebug, --------------------------
return

RemoveToolTip:
    ToolTip
return

Esc::ExitApp ; Press Esc to exit the script