param(
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [Parameter(Mandatory = $false)]
    [string]$StartupTasksConfig = "StartupTasks.config"
)

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configFile = Join-Path $scriptDir $StartupTasksConfig
if (-not (Test-Path $configFile)) {
    Write-Error "Config file '$StartupTasksConfig' not found."
    exit 1
}

$entries = Get-Content $configFile | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object { $_ -replace '%UserName%', $Username }

$startupFolder = "C:\Users\$Username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
if (-not (Test-Path $startupFolder)) {
    New-Item -Path $startupFolder -ItemType Directory -Force | Out-Null
}

$taskFolder = "\UserStartupTasks"

$existingTasks = Get-ScheduledTask -TaskPath "$taskFolder\" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TaskName
$currentTaskNames = @()

foreach ($entry in $entries) {

    $trimmed = $entry.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }

    $parts = $trimmed -split ",", 2
    if ($parts.Count -lt 2) { continue }

    $taskId = $parts[0].Trim()
    $execCmd = $parts[1].Trim()

    $safeName = $taskId -replace '[\\\/:\*\?"<>\|]', '_'
    $taskName = "Launch $safeName"
    $fullTaskPath = "$taskFolder\$taskName"

    $existingTask = Get-ScheduledTask -TaskName $taskName -TaskPath $taskFolder -ErrorAction SilentlyContinue

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"$execCmd`""

    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date)

    # Format username with domain - use computer name for local accounts or domain if joined
    $domain = if ($env:USERDOMAIN) { $env:USERDOMAIN } else { $env:COMPUTERNAME }
    $qualifiedUser = if ($Username -match '\\') { $Username } else { "$domain\$Username" }
    
    $principal = New-ScheduledTaskPrincipal -UserId $qualifiedUser -LogonType Interactive -RunLevel Highest

    if ($existingTask) {
        $currentAction = ($existingTask.Actions | Select-Object -First 1)
        if ($currentAction.Execute -ne $action.Execute -or $currentAction.Arguments -ne $action.Arguments) {
            Set-ScheduledTask -TaskName $taskName -TaskPath $taskFolder -Action $action -Trigger $trigger -Principal $principal
        }
    } else {
        Register-ScheduledTask -TaskName $taskName -TaskPath $taskFolder -Action $action -Trigger $trigger -Principal $principal -Force
    }

    $currentTaskNames += $taskName

    $shortcutName = "$taskName.lnk"
    $shortcutPath = Join-Path $startupFolder $shortcutName

    $wsh = New-Object -ComObject WScript.Shell
    $lnk = $wsh.CreateShortcut($shortcutPath)
    $lnk.TargetPath  = "C:\Windows\System32\schtasks.exe"
    $lnk.Arguments   = "/run /TN `"$fullTaskPath`""
    $lnk.WorkingDirectory = $scriptDir
    $lnk.WindowStyle = 1
    $lnk.Save()
}

# Remove tasks and shortcuts that are no longer in the config
if ($existingTasks) {
    $orphanedTasks = $existingTasks | Where-Object { $_ -notin $currentTaskNames }
    foreach ($orphanedTask in $orphanedTasks) {
        Write-Host "Removing orphaned task: $orphanedTask"
        Unregister-ScheduledTask -TaskName $orphanedTask -TaskPath $taskFolder -Confirm:$false -ErrorAction SilentlyContinue
        
        $orphanedShortcut = Join-Path $startupFolder "$orphanedTask.lnk"
        if (Test-Path $orphanedShortcut) {
            Remove-Item $orphanedShortcut -Force
            Write-Host "Removed orphaned shortcut: $orphanedShortcut"
        }
    }
}

Write-Host "Startup scheduled tasks have been created/updated successfully."