; Keep PC awake only during work time.

global KeepAwake_Active := false
global ES_CONTINUOUS := 0x80000000
global ES_SYSTEM_REQUIRED := 0x00000001
global ES_DISPLAY_REQUIRED := 0x00000002

KeepAwake()
{
    global KeepAwake_Active
    global ES_CONTINUOUS
    global ES_SYSTEM_REQUIRED
    global ES_DISPLAY_REQUIRED
    IsWorkday   := TodayIsWorkday()
    IsWorkHours := TimeIsBetween(080000, 150000)

    if (!KeepAwake_Active)
    {
        if (A_TimeIdle >= 3 * 60 * 1000 && IsWorkday && IsWorkHours)
            KeepAwake_Active := true
    }
    else
    {
        if (A_TimeIdle < 25000 || !IsWorkday || !IsWorkHours)
        {
            DllCall("SetThreadExecutionState", "UInt", ES_CONTINUOUS)
            KeepAwake_Active := false
            Return
        }
    }

    OutputDebug, % KeepAwake_Active " " IsWorkday " " IsWorkHours " " A_TimeIdle
    if (KeepAwake_Active)
    {
        DllCall("SetThreadExecutionState", "UInt", ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED)
    }
    else
    {
        DllCall("SetThreadExecutionState", "UInt", ES_CONTINUOUS)
    }
    Return
}
