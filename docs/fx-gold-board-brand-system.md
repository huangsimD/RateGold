# RateGold — Brand Identity System

**Product**: Offline FX + Gold Dashboard (#32)  
**Brand Guardian**: Agency  
**Date**: 2026-07-03  
**Status**: Approved for UI / Dev / ASO handoff  

---

## 1. 品牌定稿

### 1.1 应用命名

| 用途 | 文案 | 说明 |
|------|------|------|
| **品牌名（Logo 字标）** | **RateGold** | 短、好记；同时覆盖 Rate + Gold 两个 ASO 词根 |
| **Google Play 标题** | RateGold — FX & Gold Offline | ≤30 字符核心区；副标题含 offline / gold price |
| **内部代号** | FxGold Board | 仅文档/仓库用，不上架 |
| **包名** | `com.rategold.app` | 与品牌一致，避免 wordforge 残留 |

**弃用候选及原因**

| 候选 | 原因 |
|------|------|
| FxGold Board | 偏内部项目名；Board 对普通用户不直观 |
| RateGold: FX & Gold Price | 冒号在部分商店截断 awkward |

### 1.2 Slogan（对外）

**主 Slogan（英文 · 商店 / 开屏）**

> **Rates & gold. Offline when it matters.**

**备选（偏 SEA 汇款场景）**

> **Check rates before you send.**

**备选（偏印度/海湾金价）**

> **Today's gold price, even offline.**

**禁止用法**：不用 "Get rich"、"Investment"、"Trading signals" — 避免金融合规与误导。

### 1.3 品牌基础

| 维度 | 内容 |
|------|------|
| **Purpose** | 让跨境生活的人在网络不可靠时，仍能 honest 地查看汇率与金价 |
| **Vision** | SEA / 南亚 / 海湾最 trusted 的轻量 offline 汇率+金价工具 |
| **Mission** | 一屏看完常用货币与本地金价，三击完成换算 |
| **Values** | Honest（标注数据时间）· Lightweight · Private（无账号）· Respectful（非投资建议） |
| **Personality** | Calm · Precise · Trustworthy · Unhurried（不像炒股 App 喊涨喊跌） |

### 1.4 定位陈述

> For expats and remittance users in SEA, South Asia, and the Gulf who check FX and gold daily, **RateGold** is the offline-first dashboard that shows **both exchange rates and local gold prices** in one calm screen—unlike heavy banking apps or search results that go stale without Wi‑Fi.

---

## 2. 视觉识别系统

### 2.1 Logo 概念（供 Image Prompt / 矢量实现）

**Mark 构成**

```
┌─────────────────────────┐
│   ╭───╮                 │
│   │ ↗ │  圆角方底 + 上升折线（汇率趋势，非 K 线）│
│   ╰─●─╯  折线末端小圆点 = 金块抽象              │
│   RateGold（Inter SemiBold）                    │
└─────────────────────────┘
```

- **Symbol**：圆角正方形底（Material squircle 感）+ 单条上升折线 + 末端金色圆点  
- **含义**：Rate（折线）+ Gold（金点）；避免 ₵/$ 符号侵权感  
- **禁止**：比特币符号、K 线蜡烛、银行盾牌、国家旗帜  

### 2.2 色彩系统

#### Primary — Forest Trust（主色 · 信任/金融）

| Token | Hex | 用途 |
|-------|-----|------|
| `primary` | `#1B4332` | AppBar、Primary Button、选中 Tab |
| `onPrimary` | `#FFFFFF` | 主色上文字 |
| `primaryContainer` | `#D8E8E0` | Chip、选中行背景 |
| `onPrimaryContainer` | `#0D2818` | Container 上文字 |

#### Accent — Gold Bullion（金价/强调）

| Token | Hex | 用途 |
|-------|-----|------|
| `gold` | `#C9A227` | 金价数字、Gold strip、图标点缀 |
| `goldContainer` | `#FFF8E7` | 金价卡片背景 |
| `onGold` | `#3D2E00` | 金底上文字 |

#### Semantic

| Token | Hex | 用途 |
|-------|-----|------|
| `success` | `#2D6A4F` | 在线、同步成功 |
| `warning` | `#B8860B` | 数据过期 >24h |
| `error` | `#9B2226` | 同步失败（仍显示缓存） |
| `offline` | `#5C6570` | 离线状态条 |

#### Surface（Material 3 Light · V1 默认）

| Token | Hex |
|-------|-----|
| `surface` | `#F7F9F8` |
| `surfaceContainer` | `#FFFFFF` |
| `outline` | `#D0D7DE` |
| `onSurface` | `#1A1D21` |
| `onSurfaceVariant` | `#5C6570` |

**对比度**：正文 `#1A1D21` on `#FFFFFF` ≈ 16:1 ✓；金价 `#C9A227` on `#FFF8E7` 仅用于大数字，小字用 `#3D2E00`。

#### Dark（V1.1 可选）

| Token | Hex |
|-------|-----|
| `surface` | `#121816` |
| `primary` | `#52B788` |
| `gold` | `#E9C46A` |

### 2.3 字体

| 角色 | 字体 | 规格 |
|------|------|------|
| UI | **Inter** | 14–18sp，w400–w600 |
| 数字/汇率 | **JetBrains Mono** | 汇率、金额、金价；tabular figures |
| 禁止 | Literata 等衬线 | 避免「新闻/社论」感，与 IELTS 产品区分 |

### 2.4 图形语言

| 元素 | 规则 |
|------|------|
| 圆角 | 卡片 16dp · 按钮 12dp · Gold chip 20dp |
| 图标 | Material Symbols **Rounded** · 24dp |
| 阴影 | 轻 elevation；金融工具偏 flat |
| 摄影/插画 | 商店素材用 **3D 抽象金币+卡片**，不用真人理财顾问 |

### 2.5 商店视觉一致性清单

| 触点 | 必须出现 | 禁止 |
|------|---------|------|
| App Icon | 绿底 + 金点折线 mark | 各国国旗、Red/Green 涨跌箭头 |
| Feature Graphic | 深绿渐变 + 金 emphasis + slogan | 虚假「+500%」文案 |
| 截图 | 真实 UI mock，Inter + Mono 数字 | 与 App 不符的紫色渐变 |
| 短描述 | offline · gold · remittance | investment · trading bot |

---

## 3. 品牌声音（Voice）

| 特质 | 表达 |
|------|------|
| **Honest** | 始终带时间戳："Rates as of 09:41" |
| **Calm** | 不用「暴涨」「崩盘」 |
| **Helpful** | 短句说明 offline 仍可读上次数据 |
| **Neutral** | 免责声明可见但不吓人 |

**词汇表**

| 使用 | 避免 |
|------|------|
| rates, gold price, offline, convert, sync | live trading, profit, signals |
| as of, last updated | real-time guaranteed |

---

## 4. Google Play 文案（品牌一致）

**Short description（80 字符内）**

```
Offline FX rates & gold prices. Convert remittance currencies in one tap.
```

**Full description 首段**

```
RateGold shows exchange rates and local gold prices on one board—works offline after sync. No account. No ads. For remittance, travel, and gold shopping in SEA, India, and the Gulf.
```

**Disclaimer 块（全文末尾）**

```
Rates and gold prices are indicative only, sourced from public APIs. Not financial advice or a remittance quote.
```

---

## 5. 跨角色 Handoff

| 下游 | 文件 | 内容 |
|------|------|------|
| UI Designer | `fx-gold-board-ui-design.md` | Token 已对齐本节 |
| Image Prompt Engineer | `fx-gold-board-store-assets.md` | 色值 #1B4332 / #C9A227 写入所有 prompt |
| Flutter Dev | `app_colors.dart` | 按 Token 表实现 |
| ASO | Play 标题用 **RateGold — FX & Gold Offline** | |

---

**Brand Guardian sign-off**: 品牌名 **RateGold**、主色 **#1B4332 + #C9A227**、Slogan 与商店视觉规则已定稿，可并行开发 UI 与商店素材。
