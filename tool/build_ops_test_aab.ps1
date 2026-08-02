# Build Closed-testing AAB with ops ingest enabled (does NOT affect Production users).
# Version forced to 1.1.0+3 via --build-name / --build-number (pubspec can stay on store version).
param(
    [string]$OpsBaseUrl = "https://rategold-ops.vercel.app",
    [string]$OpsIngestToken = "",
    [string]$BuildName = "1.1.0",
    [int]$BuildNumber = 3,
    [switch]$SkipTests,
    [switch]$AllowDebugSigning
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

if ([string]::IsNullOrWhiteSpace($OpsBaseUrl)) {
    Write-Error "OpsBaseUrl is required (e.g. http://192.168.1.10:8788 for a real device)."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($OpsIngestToken)) {
    $envFile = "ops/.env"
    if (Test-Path $envFile) {
        $line = Get-Content $envFile | Where-Object { $_ -match '^\s*OPS_INGEST_TOKEN\s*=' } | Select-Object -First 1
        if ($line) {
            $OpsIngestToken = ($line -split '=', 2)[1].Trim().Trim('"').Trim("'")
        }
    }
}

$keyProps = "android/key.properties"
$hasReleaseKey = Test-Path $keyProps
if (-not $hasReleaseKey -and -not $AllowDebugSigning) {
    Write-Host "Missing android/key.properties. Pass -AllowDebugSigning for debug-signed test only."
    exit 1
}

if (-not $SkipTests) {
    Write-Host "Running tests..."
    flutter test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$appVersion = "$BuildName+$BuildNumber"
Write-Host "Building OPS test app bundle $appVersion ..."
Write-Host "OPS_BASE_URL=$OpsBaseUrl"

$defines = @(
    "OPS_BASE_URL=$OpsBaseUrl",
    "OPS_APP_VERSION=$appVersion"
)
if (-not [string]::IsNullOrWhiteSpace($OpsIngestToken)) {
    $defines += "OPS_INGEST_TOKEN=$OpsIngestToken"
}

$defineArgs = $defines | ForEach-Object { "--dart-define=$_" }

flutter build appbundle --release `
    --build-name=$BuildName `
    --build-number=$BuildNumber `
    @defineArgs

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$out = "build/app/outputs/bundle/release/app-release.aab"
if (-not (Test-Path $out)) {
    Write-Error "AAB not found at $out"
    exit 1
}

$size = (Get-Item $out).Length / 1MB
Write-Host ""
Write-Host ("Ready (Closed testing ONLY): {0} ({1:N1} MB)" -f (Resolve-Path $out), $size)
Write-Host "Upload: Play Console -> Testing -> Closed testing"
Write-Host "Do NOT upload this build to Production until Data Safety / privacy are updated."
Write-Host "Docs: docs/fx-gold-board-ops.md | docs/下版本上线功能点-1.1.0.md"
