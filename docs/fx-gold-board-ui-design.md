# RateGold — UI Design System & Screen Specs

**Product**: RateGold (Offline FX + Gold Dashboard)  
**Platform**: Flutter · Material Design 3 · Android-first  
**UI Designer**: Agency  
**Date**: 2026-07-03  
**Baseline**: 360×800 · 4dp grid  
**Brand ref**: `fx-gold-board-brand-system.md`  

**Screens in scope (5)**：Board · Convert · Settings · Manage Favorites · Sync / Offline States  

---

## Design Foundations

### Color Tokens（与 Brand 对齐）

| Token | Hex | Usage |
|-------|-----|--------|
| `primary` | `#1B4332` | AppBar, FAB-less CTA, nav indicator |
| `gold` | `#C9A227` | Gold prices, gold strip |
| `goldContainer` | `#FFF8E7` | Gold card bg |
| `surface` | `#F7F9F8` | Screen bg |
| `surfaceContainer` | `#FFFFFF` | Cards |
| `success` | `#2D6A4F` | Online sync |
| `warning` | `#B8860B` | Stale data |
| `error` | `#9B2226` | Sync failed |
| `offlineBanner` | `#E8EAED` bg / `#5C6570` text | Offline bar |

### Typography

| Role | Font | Size | Weight |
|------|------|------|--------|
| Rate hero | JetBrains Mono | 28sp | 600 |
| Gold price | JetBrains Mono | 22sp | 600 |
| Headline | Inter | 22sp | 600 |
| Title | Inter | 18sp | 600 |
| Body | Inter | 16sp | 400 |
| Caption | Inter | 12sp | 500 |
| Currency code | Inter | 14sp | 600 · letter-spacing 0.5 |

### Spacing & Shape

`4 · 8 · 12 · 16 · 20 · 24 · 32` · Card radius **16dp** · Button **12dp** · Bottom sheet top **28dp**

### Icons

Material Symbols Rounded · Rates: `currency_exchange` · Gold: `diamond` · Convert: `swap_horiz` · Offline: `cloud_off`

---

## Navigation

```
Bottom NavigationBar (3 destinations):
  Board (default) | Convert | Settings

Modals:
  Manage Favorites (full-screen or 92% sheet)
  Currency picker (searchable bottom sheet)
```

**Touch targets**: ≥ 48dp · Rate list row height **72dp**

---

## Screen 1 — Board（首页看板）

**Job**: 一屏同时回答「汇率多少」「金价多少」「数据新不新」

### Wireframe (360×800)

```
┌──────────────────────────────────────┐
│ RateGold                      ↻      │  AppBar 56 · refresh icon
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ ● Online · Updated 09:41 GST     │ │  Sync bar 40 · success dot
│ └──────────────────────────────────┘ │
│                                      │
│  GOLD TODAY                    See all│  Section label
│  ┌────────┐ ┌────────┐ ┌────────┐   │
│  │ 🇮🇳 INR │ │ 🇦🇪 AED │ │ 🇵🇭 PHP │   │  Horizontal scroll · 140×88 each
│  │24K/10g │ │ 24K/g  │ │ 24K/g  │   │
│  │ ₹7,842 │ │ 312.50 │ │ 4,128  │   │  Mono 22sp gold color
│  └────────┘ └────────┘ └────────┘   │
│                                      │
│  MY RATES · Base: USD                │
│  ┌──────────────────────────────────┐│
│  │ AED  UAE Dirham          3.6725   ││  Row 72dp
│  │                              →   ││
│  ├──────────────────────────────────┤│
│  │ PHP  Philippine Peso    56.24    ││
│  ├──────────────────────────────────┤│
│  │ INR  Indian Rupee       83.12    ││
│  ├──────────────────────────────────┤│
│  │ IDR  Indonesian Rupiah  15,840   ││
│  └──────────────────────────────────┘│
│                                      │
│  [ ＋ Add currency ]                 │  Outlined button
├──────────────────────────────────────┤
│  Board    Convert    Settings        │  NavigationBar
└──────────────────────────────────────┘
```

### States

| State | UI |
|-------|-----|
| **Loading** | Gold strip + list skeleton shimmer |
| **Offline** | Banner: `cloud_off` + "Offline · Rates as of 2 Jul 09:41" |
| **Stale (>24h)** | Gold cards amber border + caption "May be outdated" |
| **Pull refresh** | Material 3 refresh indicator · primary color |
| **Empty favorites** | Illustration + "Add currencies you check most" |

### Interactions

- Tap rate row → Convert 预填 From  
- Tap gold card → 展开该市场详情（V1 可 toast 来源说明）  
- ↻ / pull → sync（15min throttle 时 toast "Updated recently"）

---

## Screen 2 — Convert（换算）

**Job**: 3 秒内完成「500 AED = ? PHP」

### Wireframe

```
┌──────────────────────────────────────┐
│ ← Convert                            │
├──────────────────────────────────────┤
│                                      │
│  FROM                                │
│  ┌──────────────────────────────────┐│
│  │  AED ▾          │  500          ││  56dp input
│  └──────────────────────────────────┘│
│              ⇅ swap (48dp)           │
│  TO                                  │
│  ┌──────────────────────────────────┐│
│  │  PHP ▾          │  2,812.00       ││  Result read-only · Mono
│  └──────────────────────────────────┘│
│                                      │
│  Rate: 1 AED = 5.6240 PHP            │  Caption · as of time
│  Indicative only · Not a bank quote  │  12sp variant
│                                      │
│  ┌──────────────────────────────────┐│
│  │ Quick: 100   500   1000   Custom   ││  Filter chips
│  └──────────────────────────────────┘│
│                                      │
│  [ Copy result ]                     │  Outlined · full width
│                                      │
├──────────────────────────────────────┤
│  Board    Convert    Settings        │
└──────────────────────────────────────┘
```

### Behavior

- 金额输入即算 · 非法输入 shake + hint  
- Swap 交换 from/to 并保留金额  
- 键盘：numeric · decimal  

---

## Screen 3 — Settings（设置）

**Job**: 基准货币、收藏、同步、合规入口

### Wireframe

```
┌──────────────────────────────────────┐
│ Settings                             │
├──────────────────────────────────────┤
│  PREFERENCES                         │
│  ┌──────────────────────────────────┐│
│  │ Base currency          USD ▾     ││
│  │ Manage favorites (5/8)        >  ││
│  │ Gold markets display          >  ││
│  └──────────────────────────────────┘│
│  DATA                                │
│  ┌──────────────────────────────────┐│
│  │ Sync now                    ↻    ││
│  │ Last sync: Today 09:41           ││
│  │ Offline cache: 847 KB            ││
│  └──────────────────────────────────┘│
│  ABOUT                               │
│  ┌──────────────────────────────────┐│
│  │ Privacy policy                 > ││
│  │ Data sources & disclaimer      > ││
│  │ Version 1.0.0                    ││
│  └──────────────────────────────────┘│
│                                      │
│  "Rates & gold. Offline when it      │  Brand slogan · caption centered
│   matters."                          │
├──────────────────────────────────────┤
│  Board    Convert    Settings        │
└──────────────────────────────────────┘
```

---

## Screen 4 — Manage Favorites（管理收藏）

**Presentation**: 92% height bottom sheet 或 full-screen push

### Wireframe

```
┌──────────────────────────────────────┐
│ Manage favorites              Done   │
│ Up to 8 · drag to reorder            │
├──────────────────────────────────────┤
│  ≡  AED   UAE Dirham            ✕    │  Drag handle · remove
│  ≡  PHP   Philippine Peso       ✕    │
│  ≡  INR   Indian Rupee          ✕    │
│  ...                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
│  🔍 Search currency                  │
│  Suggested: SAR · EUR · GBP · MYR    │  Chips add
└──────────────────────────────────────┘
```

---

## Screen 5 — Sync & Offline States（系统态）

非独立 Tab，作为 **Board 变体** 文档化供 Dev QA。

### 5a Offline Board

```
┌──────────────────────────────────────┐
│ ░ Offline · Rates as of 1 Jul 18:20 ░│  full-width banner · offlineBanner
│ ... (Board content dimmed 0% — still readable) │
└──────────────────────────────────────┘
```

### 5b Sync failed (cached)

```
┌──────────────────────────────────────┐
│ ⚠ Sync failed · Showing saved data  │  error color icon · dismissible
└──────────────────────────────────────┘
```

### 5c First launch empty

```
        [ cloud_download icon 64dp ]
        Syncing rates for the first time…
        [ linear progress ]
        Or use bundled data if offline
```

---

## Component Library

### RateListTile

| Prop | Spec |
|------|------|
| Height | 72dp |
| Leading | 40dp circle · currency code 3 letters |
| Title | Full currency name · bodyLarge |
| Trailing | Rate Mono 18sp · chevron optional |
| Divider | 1dp outline between rows |

### GoldMarketChip

| Prop | Spec |
|------|------|
| Size | 140×88dp |
| BG | goldContainer |
| Label | market + unit caption |
| Value | Mono 22sp · gold color |

### SyncStatusBar

| Prop | Spec |
|------|------|
| Height | 40dp |
| Online | success dot + timestamp |
| Offline | cloud_off + last sync |

### Buttons

| Type | Spec |
|------|------|
| Filled | primary bg · 48dp height · 12dp radius |
| Outlined | 1dp outline · primary text |
| Text | "Add currency" links |

---

## Accessibility

- 所有汇率朗读：`Semantics(label: '1 UAE Dirham equals 3.6725 US dollars')`  
- 金价卡片：含单位 `"24 karat gold, 7842 rupees per 10 grams"`  
- 对比度 WCAG AA · 数字缩放至 200% 不断行（Mono 允许 wrap）  
- Reduce motion：禁用 shimmer，用静态 placeholder  

---

## Flutter Handoff Checklist

- [ ] `ColorScheme.fromSeed(seedColor: Color(0xFF1B4332))` + gold custom extension  
- [ ] `google_fonts`: Inter + JetBrains Mono  
- [ ] `NavigationBar` 3 tabs · `go_router`  
- [ ] Board `RefreshIndicator` + sync controller  
- [ ] Convert `TextField` with `TextInputType.numberWithOptions(decimal: true)`  

---

**UI Designer sign-off**: 5 屏规格与 Material 3 组件库已就绪，可直接对照实现。
