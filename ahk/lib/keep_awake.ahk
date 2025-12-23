; Background mouse-nudge to keep awake only during workdays and hours.

KeepAwake()
{
    IsWorkday   := TodayIsWorkday()
    IsWorkHours := TimeIsBetween(080000, 150000)
    IsIdle      := A_TimeIdle >= 3 * 60 * 1000  ; 3 minutes

    OutputDebug, % IsIdle " " IsWorkday " " IsWorkHours " " A_TimeIdle
    if (IsIdle && IsWorkday && IsWorkHours)
    {
        MouseMove, 1, 0, 1, R  ; Move the mouse one pixel to the right
        MouseMove, -1, 0, 1, R ; Move it back
    }
    Return
}
