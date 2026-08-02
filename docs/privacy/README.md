# Deploy privacy policy to Vercel

Production URL: **https://privacy-two-pi.vercel.app/**

In-app preview uses native Flutter UI (`lib/widgets/privacy_policy_body.dart`). Keep in sync with `index.html` and `assets/legal/privacy_policy.html`.

```powershell
# From repo root (requires: npx vercel login once)
Remove-Item Env:VERCEL_TOKEN -ErrorAction SilentlyContinue
Set-Location docs/privacy
npx --yes vercel@latest --prod --yes
```

After editing `index.html`, rerun the command above to publish updates.
