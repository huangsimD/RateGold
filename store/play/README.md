# RateGold — Google Play Store Assets (D9)

Upload-ready assets for Google Play Console.

## Files

| File | Size | Use |
|------|------|-----|
| `icon-512.png` | 512×512 | Play listing **App icon** |
| `icon-1024.png` | 1024×1024 | Master / `flutter_launcher_icons` source |
| `feature-graphic-1024x500.png` | 1024×500 | Play **Feature graphic** |
| `screenshots/*.png` | 1080×1920 (target) | Phone screenshots ×4 |

Brand colors: `#1B4332` · `#C9A227` · `#F7F9F8`

## Regenerate icons

```bash
dart run tool/prepare_store_assets.dart
dart run flutter_launcher_icons
```

## Capture screenshots (recommended)

**Do not use** `flutter test integration_test/...` on a physical device — it rebuilds and reinstalls a **test harness APK** every run (slow; often hangs on Huawei).

One-time install, then adb capture:

```powershell
# 1. Install app once (only when code changed)
flutter install -d APH0219A14014169

# 2. Capture 4 screens via deep links (no reinstall)
powershell -File tool/capture_store_screenshots.ps1 -Device APH0219A14014169
```

Routes used: Board `/` · Convert `/convert` · Settings `/settings` · Gold `/gold`.

Composite captions in Figma using copy from `docs/fx-gold-board-store-assets.md`:

| # | Caption (EN) |
|---|----------------|
| 1 | FX & gold on one board · Works offline after sync |
| 2 | Convert in one tap |
| 3 | No account · No ads |
| 4 | Gold prices across SEA & Gulf markets |

## QA checklist

- [ ] Icon readable at 48dp (gold dot visible)
- [ ] Feature graphic: no implied investment returns
- [ ] Screenshots match current UI (Board / Convert / Settings / Gold)
- [ ] Colors within ±5% of brand tokens

See also: `docs/fx-gold-board-store-assets.md` for AI prompt archive.

## Compliance (D10)

| Item | Path |
|------|------|
| Privacy policy (HTML) | `docs/privacy/index.html` → https://privacy-two-pi.vercel.app/ |
| Data Safety 填写指南 | `docs/fx-gold-board-data-safety.md` |
| In-app link | Settings → Privacy policy |
