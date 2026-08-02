# Creates upload keystore + android/key.properties for Play Production signing.
# Run once per app; back up the .jks and passwords offline.
param(
    [string]$Alias = "upload",
    [string]$KeystorePath = "android/keystore/rategold-upload.jks",
    [int]$ValidityDays = 10000,
    [switch]$NonInteractive,
    [string]$DName = "CN=RateGold, OU=Mobile, O=RateGold, L=Dubai, ST=Dubai, C=AE"
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

function Find-Keytool {
    $cmd = Get-Command keytool -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        $env:JAVA_HOME,
        "D:\Android\Android Studio\jbr",
        "C:\Program Files\Android\Android Studio\jbr",
        "C:\Program Files\Java\jdk-17",
        "C:\Program Files\Eclipse Adoptium\jdk-17*"
    )
    foreach ($base in $candidates) {
        if (-not $base) { continue }
        $resolved = $base
        if ($base -like '*`*') {
            $hit = Get-Item $base -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($hit) { $resolved = $hit.FullName }
        }
        $path = Join-Path $resolved "bin\keytool.exe"
        if (Test-Path $path) { return $path }
    }
    return $null
}

function New-RandomPassword {
    $bytes = New-Object byte[] 24
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return ([Convert]::ToBase64String($bytes) -replace '[^a-zA-Z0-9]', '').Substring(0, 24)
}

$keyProps = "android/key.properties"
if (Test-Path $keyProps) {
    Write-Host "Already exists: $keyProps"
    Write-Host "Delete it first if you need a new keystore."
    exit 1
}

$keytool = Find-Keytool
if (-not $keytool) {
    Write-Error "keytool not found. Install JDK or Android Studio JBR."
}

$dir = Split-Path $KeystorePath -Parent
if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

Write-Host "Create upload keystore for RateGold (com.rategold.app)"
Write-Host "Using keytool: $keytool"
Write-Host ""

if ($NonInteractive) {
    $storePlain = New-RandomPassword
    $keyPlain = $storePlain
    Write-Host "NonInteractive: generated random store/key passwords."
    & $keytool -genkeypair -v `
        -keystore $KeystorePath `
        -alias $Alias `
        -keyalg RSA `
        -keysize 2048 `
        -validity $ValidityDays `
        -storepass $storePlain `
        -keypass $keyPlain `
        -dname $DName
} else {
    Write-Host "You will be prompted for Distinguished Name fields and passwords."
    & $keytool -genkeypair -v `
        -keystore $KeystorePath `
        -alias $Alias `
        -keyalg RSA `
        -keysize 2048 `
        -validity $ValidityDays

    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host ""
    Write-Host "Enter the SAME store password again for key.properties:"
    $storePass = Read-Host "Store password" -AsSecureString
    $storePlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePass))

    Write-Host "Enter key password (often same as store password):"
    $keyPass = Read-Host "Key password" -AsSecureString
    $keyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPass))
}

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$relStore = "keystore/" + (Split-Path $KeystorePath -Leaf)
$content = @"
storePassword=$storePlain
keyPassword=$keyPlain
keyAlias=$Alias
storeFile=$relStore
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path (Get-Location) $keyProps), $content, $utf8NoBom)

if ($NonInteractive) {
    $credFile = Join-Path $dir "UPLOAD_KEY_CREDENTIALS.txt"
    @"
RateGold upload keystore — BACK UP OFFLINE, do not commit.
Generated: $(Get-Date -Format o)
Keystore: $KeystorePath
Alias: $Alias
Store password: $storePlain
Key password: $keyPlain
"@ | Set-Content -Path $credFile -Encoding UTF8
    Write-Host ""
    Write-Host "Passwords saved locally (gitignored): $credFile"
}

Write-Host ""
Write-Host "Created:"
Write-Host "  $KeystorePath"
Write-Host "  $keyProps"
Write-Host ""
Write-Host "BACK UP the .jks file and passwords securely (password manager / offline copy)."
Write-Host "Next: powershell -File tool/build_release_aab.ps1"
