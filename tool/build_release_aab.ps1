# Build Production release AAB (requires android/key.properties).
param(
    [switch]$SkipTests,
    [switch]$AllowDebugSigning
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$keyProps = "android/key.properties"
$hasReleaseKey = Test-Path $keyProps

if (-not $hasReleaseKey -and -not $AllowDebugSigning) {
    Write-Host "Missing android/key.properties (release signing not configured)."
    Write-Host ""
    Write-Host "  1. Copy android/key.properties.example -> android/key.properties"
    Write-Host "  2. Or run: powershell -File tool/create_release_keystore.ps1"
    Write-Host ""
    Write-Host "For internal testing only, pass -AllowDebugSigning"
    exit 1
}

if (-not $hasReleaseKey) {
    Write-Warning "Building with DEBUG signing — not valid for Production track."
}

if (-not $SkipTests) {
    Write-Host "Running tests..."
    flutter test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# Production builds must NOT pass OPS_BASE_URL / OPS_INGEST_TOKEN (ops ingest stays off).
Write-Host "Building release app bundle (ops ingest disabled)..."
flutter build appbundle --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$out = "build/app/outputs/bundle/release/app-release.aab"
if (-not (Test-Path $out)) {
    Write-Error "AAB not found at $out"
    exit 1
}

$size = (Get-Item $out).Length / 1MB
Write-Host ""
Write-Host ("Ready: {0} ({1:N1} MB)" -f (Resolve-Path $out), $size)

if ($hasReleaseKey) {
    $props = Get-Content $keyProps | Where-Object { $_ -match '=' }
    $map = @{}
    foreach ($line in $props) {
        $k, $v = $line -split '=', 2
        $map[$k.Trim()] = $v.Trim()
    }
    $storeFile = Join-Path "android" $map['storeFile']
    if (Test-Path $storeFile) {
        Write-Host ""
        Write-Host "Upload certificate SHA-256 (for Play App Signing reference):"
        $keytool = $null
        if (Get-Command keytool -ErrorAction SilentlyContinue) {
            $keytool = "keytool"
        } elseif (Test-Path "D:\Android\Android Studio\jbr\bin\keytool.exe") {
            $keytool = "D:\Android\Android Studio\jbr\bin\keytool.exe"
        } elseif (Test-Path "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe") {
            $keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
        }
        if ($keytool) {
            & $keytool -list -v -keystore $storeFile -alias $map['keyAlias'] -storepass $map['storePassword'] 2>$null |
                Select-String "SHA256:"
        }
    }
}

Write-Host ""
Write-Host "Upload: Play Console -> Release -> Production -> Create new release"
Write-Host "Checklist: docs/fx-gold-board-production-submit.md"
