param(
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [Parameter(Mandatory = $false)]
    [string]$LinksConfig = "Links.config",
    [Parameter(Mandatory = $false)]
    [string]$StartupTasksConfig = "StartupTasks.config"
)

if (-Not(Test-Path $LinksConfig)) {
    Write-Host "Configuration file not found: $LinksConfig"
    exit
}

$configFileContent = Get-Content $LinksConfig

foreach ($row in $configFileContent) {
    $parts = $row -split ',', 2

    if ($parts.Length -ne 2) {
        Write-Host "Invalid row format: $row"
        exit
    }

    $sourcePath = $parts[0]
    $destinationPath = $parts[1]
    $destinationPath = $destinationPath.Replace('~', $env:USERPROFILE)

    if ($sourcePath -match '\*$') {
        $sourceDir = Split-Path $sourcePath -Parent
        $destDir = Split-Path $destinationPath -Parent

        if (-Not(Test-Path $sourceDir)) {
            Write-Host "Directory not found: $sourceDir"
            exit
        }

        if (-Not(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        $files = Get-ChildItem -Path $sourceDir -File
        foreach ($file in $files) {
            $fileSourcePath = $file.FullName
            $fileDestPath = Join-Path $destDir $file.Name

            if (Test-Path $fileDestPath) {
                if (-Not(Get-Item $fileDestPath).LinkType -eq "SymbolicLink") {
                    Write-Host "File already exists: $fileDestPath; back it up before continuing."
                    exit
                }
            }

            New-Item -ItemType SymbolicLink -Path $fileDestPath -Target $fileSourcePath -Force
        }
        continue
    }

    if (-Not(Test-Path $sourcePath)) {
        Write-Host "File not found: $sourcePath"
        exit
    }

    if (Test-Path $destinationPath) {
        if (-Not(Get-Item $destinationPath).LinkType -eq "SymbolicLink") {
            Write-Host "File already exists: $destinationPath; back it up before continuing."
            exit
        }
    }

    New-Item -ItemType SymbolicLink -Path $destinationPath -Target $sourcePath -Force
}

.\Create-StartupScheduledTasks.ps1 -Username $Username