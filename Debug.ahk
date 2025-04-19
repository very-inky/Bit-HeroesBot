#SingleInstance, Force
DebugLog(msg) {
    OutputDebug, % msg " Orion"
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    FileAppend, % timestamp " - " msg "`n", debug_log.txt
}