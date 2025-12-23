# $gitRoot = (git rev-parse --show-toplevel -q 2>$null)
# if (-Not($gitRoot)) {
#     Write-Host "Not inside a Git repository or Git is not installed."
#     exit
# }

$configFilePath = "links.config"

if (-Not(Test-Path $configFilePath)) {
    Write-Host "Configuration file not found: $configFilePath"
    exit
}

$configFileContent = Get-Content $configFilePath

foreach ($row in $configFileContent) {
    $parts = $row -split ',', 2

    if ($parts.Length -ne 2) {
        Write-Host "Invalid row format: $row"
        exit
    }

    $sourcePath = $parts[0]
    $destinationPath = $parts[1]
    $destinationPath = $destinationPath.Replace('~', $env:USERPROFILE)

    # Handle wildcard (*) to expand to all files in a directory
    if ($sourcePath -match '\*$') {
        $sourceDir = Split-Path $sourcePath -Parent
        $destDir = Split-Path $destinationPath -Parent

        if (-Not(Test-Path $sourceDir)) {
            Write-Host "Directory not found: $sourceDir"
            exit
        }

        # Ensure destination directory exists
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
