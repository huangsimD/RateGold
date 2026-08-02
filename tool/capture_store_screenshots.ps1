# Capture 4 Play Store screenshots via adb + deep links (no integration_test reinstall).
# Prerequisite: app installed once — flutter install -d <device_id>
param(
    [string]$Device = "",
    [string]$OutDir = "store/play/screenshots",
    [int]$WaitSeconds = 4
)

$ErrorActionPreference = "Stop"
$pkg = "com.rategold.app"

function Invoke-AdbCommand {
    param([string[]]$CommandArgs)
    if ($Device) {
        & adb -s $Device @CommandArgs
    } else {
        & adb @CommandArgs
    }
    if ($LASTEXITCODE -ne 0) {
        throw "adb failed: adb $($CommandArgs -join ' ')"
    }
}

function Save-AdbScreenshot {
    param([string]$DestPath)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "adb"
    if ($Device) {
        $psi.Arguments = "-s $Device exec-out screencap -p"
    } else {
        $psi.Arguments = "exec-out screencap -p"
    }
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $proc = [System.Diagnostics.Process]::Start($psi)
    $ms = New-Object System.IO.MemoryStream
    $proc.StandardOutput.BaseStream.CopyTo($ms)
    $proc.WaitForExit()
    if ($proc.ExitCode -ne 0) {
        throw "adb screencap failed (exit $($proc.ExitCode))"
    }
    [System.IO.File]::WriteAllBytes($DestPath, $ms.ToArray())
}

$shots = @(
    @{ Name = "01_board"; Uri = "rategold://app/" },
    @{ Name = "02_convert"; Uri = "rategold://app/convert" },
    @{ Name = "03_settings"; Uri = "rategold://app/settings" },
    @{ Name = "04_gold_markets"; Uri = "rategold://app/gold" }
)

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "Checking device..."
Invoke-AdbCommand @("get-state") | Out-Null

Write-Host "No reinstall — launching deep links and screencap."
foreach ($shot in $shots) {
    Write-Host "-> $($shot.Name) ($($shot.Uri))"
    Invoke-AdbCommand @("shell", "am", "force-stop", $pkg) | Out-Null
    Start-Sleep -Seconds 1
    Invoke-AdbCommand @(
        "shell", "am", "start",
        "-a", "android.intent.action.VIEW",
        "-d", $shot.Uri,
        $pkg
    ) | Out-Null
    Start-Sleep -Seconds $WaitSeconds
    $dest = Join-Path $OutDir "$($shot.Name).png"
    Save-AdbScreenshot -DestPath $dest
    $size = (Get-Item $dest).Length
    Write-Host "   saved $dest ($size bytes)"
}

Write-Host "Done."
