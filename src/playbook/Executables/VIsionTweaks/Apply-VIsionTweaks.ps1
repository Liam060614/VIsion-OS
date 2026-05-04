$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSCommandPath
$scripts = @(
    "Remove_Delay.bat",
    "Fortnite_Tweak.bat"
)

foreach ($script in $scripts) {
    $path = Join-Path $root $script

    if (!(Test-Path -LiteralPath $path)) {
        throw "Missing VIsion tweak script: $path"
    }

    Write-Host "Running $script"
    $process = Start-Process -FilePath "$env:ComSpec" -ArgumentList "/c", "`"$path`"" -Wait -PassThru -WindowStyle Hidden

    if ($process.ExitCode -ne 0) {
        throw "$script failed with exit code $($process.ExitCode)"
    }
}

Write-Host "VIsion OS tweaks applied successfully."
