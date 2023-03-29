$gitRoot = (git rev-parse --show-toplevel -q 2>$null)
if (-Not($gitRoot)) {
    Write-Host "Not inside a Git repository or Git is not installed."
    exit
}

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

    if (-Not(Test-Path $sourcePath)) {
        Write-Host "File not found: $sourcePath"
        exit
    }

    New-Item -ItemType SymbolicLink -Path $destinationPath -Target $sourcePath -Force
}
