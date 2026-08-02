# Build release AAB for Google Play internal testing track.
Set-Location $PSScriptRoot\..

Write-Host "Running tests..."
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Building app bundle..."
flutter build appbundle --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$out = "build/app/outputs/bundle/release/app-release.aab"
if (Test-Path $out) {
    $size = (Get-Item $out).Length / 1MB
    Write-Host ("Ready: {0} ({1:N1} MB)" -f $out, $size)
    Write-Host "Upload to Play Console -> Testing -> Internal testing"
} else {
    Write-Error "AAB not found"
    exit 1
}
