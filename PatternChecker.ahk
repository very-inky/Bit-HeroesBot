;resolution and scaling tester
#SingleInstance, Force
#Persistent
SetBatchLines, -1

; --- Ensure FindText.ahk is in the same directory
#Include FindText.ahk


; --- Configuration Variables to Test ---
TestPattern       := "|<>*151$121.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs003s1zk007k7z0T0001w001w0zs003s3zUDU000y000y0Tw001w1zk7k000E000T0DU000y0zs3s0008000DU7k000T0Tw1w00040007k3s000DUDy0y00020003s1w000Dk7z0T00010Tzzw0y0zzzs3zUDzs3zUDzzy0T0Tzzw1zk7zw1zk7zzz0DUDzzy0zs3zy0zs1zzzU7k7zzz0Tw1zz0Tw00Tzk3s3s0DU000zzUDy00Dzs1w1w07k000Tzk7z007zw0y0y03s000Dzs3zU03zy0T0T01w0007zw1zk01zz0DUDU0y0003zy0zs00zzU7k7k0T0001zz0Tw00Tzk3s3s0DU000zzUDy0zzzs1w1zk7k7z0Tzk7z0Tzzw0y0zs3s3zUDzs3zUDzzy0T0Tw1w1zk7zw1zk7zzz0DUDy0y0zs3zy0zs3zzzU7k000T0Tw1zz0Tw1zzzk3s000DUDy0zzUDy0zzzs1w0007k7z0Tzk7z0Tzzw0zs00zs3zUDzs3zUDzzy0Tw00Tw1zk7zw1zk7zzz0Dy00Dy0zs3zy0zs3zzzU7z007z0Tw1zz0TzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
                                             ; Replace with your pattern to test

TestZoomW         := 1.0  ; Zoom factor for width (1.0 = 100% = no correction)
TestZoomH         := 1.0  ; Zoom factor for height (1.0 = 100% = no correction)

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