# RateGold — Store Assets & AI Image Prompts

**Image Prompt Engineer**: Agency  
**Brand ref**: `fx-gold-board-brand-system.md`  
**UI ref**: `fx-gold-board-ui-design.md`  
**Date**: 2026-07-03  
**Target platforms**: Midjourney v6 · DALL·E 3 · Flux · Google Play asset specs  

---

## Asset Inventory

| Asset | Size | Format | Priority |
|-------|------|--------|----------|
| App Icon | 512×512 (Play) | PNG | P0 |
| Adaptive Icon fg | 432×432 safe zone | PNG | P0 |
| Feature Graphic | 1024×500 | PNG/JPG | P0 |
| Phone Screenshot ×4 | 1080×1920 min | PNG | P0 |
| Promo tile (optional) | 180×120 | PNG | P2 |

**Brand colors in all assets**: Primary `#1B4332` · Gold `#C9A227` · Surface `#F7F9F8` · Text `#1A1D21`

---

## 1. App Icon (512×512)

### Creative direction

- Squircle app icon, **deep forest green** `#1B4332` background  
- Center mark: **minimal white upward trend line** + **gold circle dot** at line end (Rate + Gold)  
- Flat Material Design 3 style, **no text** on icon  
- Subtle inner shadow for depth, not skeuomorphic coin stack  

### Midjourney prompt

```
Mobile app icon design, perfect squircle shape, solid deep forest green background color #1B4332, centered minimalist symbol: single white upward diagonal line chart stroke with small golden circle dot #C9A227 at the peak, flat Material Design 3 aesthetic, clean vector-like edges, subtle soft vignette, no text, no letters, no flags, no bitcoin symbol, professional fintech app icon, centered composition, 512x512, ultra clean, app store ready --ar 1:1 --v 6 --style raw
```

**Negative prompt**

```
text, letters, watermark, 3D coins pile, dollar sign, euro sign, national flags, candlestick chart, stock trading, neon, gradient rainbow, photorealistic human, busy details, drop shadow on white square background
```

### DALL·E 3 prompt

```
A flat mobile app icon in squircle shape. Background is solid deep forest green (#1B4332). Center: a minimal white line trending upward with a small gold (#C9A227) dot at the end of the line. Material Design 3 style, vector clean, no text, no currency symbols, no flags. Professional finance utility app. Square 1024x1024.
```

### Flux prompt

```
Flat app icon squircle, deep green #1B4332 background, minimalist white upward trend line ending in gold dot #C9A227, Material Design 3, vector clean, no typography, fintech utility, centered, high contrast, 512px
```

### Post-production

1. Export 512×512 PNG  
2. Adaptive icon: foreground only on transparent 432×432 (mark scaled 66%)  
3. Background layer: solid `#1B4332` full bleed  

---

## 2. Feature Graphic (1024×500)

### Creative direction

- **Left 40%**: large app icon mark + wordmark **RateGold** (Inter SemiBold)  
- **Right 60%**: stylized phone mock showing green UI with gold price cards (可后期合成真实截图)  
- Background: gradient `#1B4332` → `#0D2818` subtle  
- Slogan: **Rates & gold. Offline when it matters.**  
- No fake percentage gains  

### Midjourney prompt (background + device mood)

```
Google Play feature graphic banner 1024x500, split layout, left side deep forest green #1B4332 gradient background with abstract minimalist gold line graph and small gold sphere accent, right side modern Android smartphone mockup showing clean finance dashboard UI with white cards and gold highlighted numbers, Material Design 3, calm trustworthy fintech aesthetic, soft studio lighting, no human faces, no stock market red green arrows, no misleading profit text, professional app store marketing, wide cinematic composition --ar 1024:500 --v 6
```

**Negative**

```
cryptocurrency logos, trading charts candles, luxury gold bars photo, cash money piles, national flags, cluttered text blocks, meme style, low resolution
```

### Composite instructions (Figma / Canva)

1. Place AI background or solid gradient `#1B4332`  
2. Overlay **actual UI screenshot** from Board screen (1080×2400 crop) at 18° slight perspective optional  
3. Add wordmark **RateGold** white + slogan 14pt `#FFFFFF` 80% opacity  
4. Safe zone: keep text/mark within center 80% (Play crops edges on some devices)  

---

## 3. Store Screenshots (1080×1920 × 4)

**Rule**: Use **real Flutter UI** renders when available; AI generates **device frame / lifestyle background only**.

### Screenshot 1 — Board Hero

**Caption overlay (top)**: `FX & gold on one board`  
**Caption (bottom)**: `Works offline after sync`

**UI content**: Board screen · Online sync bar · Gold strip INR/AED/PHP · Rate list  

**Background prompt (optional frame)**

```
Minimal soft gradient background #F7F9F8 to #D8E8E0, subtle abstract circular shapes, clean app store screenshot backdrop, no device, empty center for UI overlay, professional, calm --ar 9:16
```

### Screenshot 2 — Convert

**Caption**: `Convert in one tap`  
**UI**: Convert screen · 500 AED → PHP result  

### Screenshot 3 — Offline

**Caption**: `Still readable offline`  
**UI**: Board with offline banner · timestamp visible  

### Screenshot 4 — Privacy / Trust

**Caption**: `No account · No ads`  
**UI**: Settings screen · Privacy row highlighted  

### Device frame prompt (Midjourney · optional)

```
Modern Android smartphone frame mockup, thin bezels, neutral shadow on light gray studio background, front view, empty black screen placeholder for UI composite, product photography style, soft diffused lighting, 9:16 aspect, commercial quality --ar 9:16
```

---

## 4. Supplementary Assets

### 4.1 Splash / Launch (Android 12+)

- Solid `#1B4332` + centered white/gold mark only  
- No slogan (load time <300ms perceived)  

### 4.2 Empty state illustration

```
Minimal line illustration, single gold coin with small exchange arrows, forest green #1B4332 and gold #C9A227 only, white background, friendly calm style, no characters, SVG-friendly simple shapes --ar 1:1
```

### 4.3 Promo badge (optional)

```
Small rounded rectangle badge graphic, text area blank, gold border #C9A227 on green fill #1B4332, flat Material style, "offline" concept subtle cloud icon, 180x120 --ar 3:2
```

---

## 5. Platform Parameters Cheat Sheet

| Platform | Parameter | Value |
|----------|-----------|-------|
| Midjourney | `--ar` icon | `1:1` |
| Midjourney | `--ar` feature | `1024:500` or `2:1` |
| Midjourney | `--style raw` | icons (cleaner) |
| DALL·E | Size icon | 1024×1024 |
| Play Console | Icon | 512 PNG 32-bit |
| Play Console | Feature | 1024×500 JPG/PNG |

---

## 6. QA Checklist (Brand Guardian alignment)

- [ ] Icon readable at 48×48 dp (gold dot still visible)  
- [ ] No implied investment returns on Feature Graphic  
- [ ] Screenshot captions match **RateGold** voice (honest, calm)  
- [ ] Colors within ±5% of `#1B4332` / `#C9A227`  
- [ ] UI screenshots match `fx-gold-board-ui-design.md` layout  
- [ ] Disclaimer not required on icon; present in Store full description  

---

## 7. Generation Workflow

1. **Generate icon** with Midjourney/DALL·E → pick cleanest mark  
2. **Vector trace** in Figma (optional) for adaptive icon layers  
3. **Build Flutter UI** → capture 4 screenshots on 360×800 emulator scaled to 1080×1920  
4. **Composite** Feature Graphic: icon + screenshot + slogan in Figma template  
5. **Upload** Play Console · verify preview on phone and tablet listing  

---

**Image Prompt Engineer sign-off**: 以上 prompt 可直接复制到 Midjourney / DALL·E / Flux；商店截图优先用真实 UI 合成，AI 负责背景与营销底图。
