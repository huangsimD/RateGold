# RateGold — API 降级与 Seed 策略 (D14)

**Date**: 2026-07-04  
**Scope**: Frankfurter FX · bundled gold · offline resilience  

---

## 1. 设计目标

| 场景 | 用户应看到 | 连接状态 |
|------|-----------|----------|
| 在线 + API 正常 | 最新 ECB 日频汇率 | Online |
| 用户基准币 API 不支持 | USD 拉取 + 重算为用户基准 | Online |
| API 超时 / 5xx | 上次缓存 + seed 补缺 | Sync failed |
| 无网络 | 上次缓存或 bundled seed | Offline |
| 首次安装无网 | `assets/data/*.json` | Offline |

原则：**宁可标注「同步失败 / 截至 xx:xx」，也不伪造实时价。**

---

## 2. 汇率同步降级链

```
1. Frankfurter latest?from={userBase}&to={symbols}
   ↓ 失败或 rates 为空
2. Frankfurter latest?from=USD&to={symbols + userBase}
   ↓ 成功且 userBase ≠ USD
3. rebaseUsdSnapshot() → 转为 userBase 报价
   ↓ 仍失败
4. 有缓存 → seed merge 补强 → Sync failed
   无缓存 → bundled rates_seed.json → Offline
```

实现位置：

- `lib/services/rates_repository.dart` — `_fetchRatesWithFallback()`
- `lib/services/fx_fallback.dart` — `rebaseUsdSnapshot()`
- `_mergeRatesWithSeed()` — 缺失 / 为 0 的币种用 USD seed 三角换算

---

## 3. 金价策略（V1 无 live Gold API）

| 层级 | 来源 | 说明 |
|------|------|------|
|  bundled | `assets/data/gold_seed.json` | 发版时更新参考 spot |
|  cache | `gold_snapshot.json` | 上次 sync 写入 |
|  展示 | `GoldCalculator` | spot × FX → 本地单位 |

**Sync 成功时**：FX 来自 Frankfurter；金价 spot 仍用 bundled 文件中的 `usdPerOz`（避免假装 live gold API）。`updatedAt` 刷新为 sync 时间，来源文案 `bundled spot · FX synced`。

**Init 时**：若 cache 中金价 `updatedAt` 超过 **7 天**，回写 bundled seed（防止极旧 spot 长期不更新）。

UI：spot 超过 **24h** 未更新 → 卡片 amber 边框（已有逻辑）。

---

## 4. Bundled Seed 更新（2026-07-04）

| 文件 | 更新内容 |
|------|----------|
| `assets/data/rates_seed.json` | date/fetchedAt → 2026-07-04；微调 AED/PHP/INR 等 |
| `assets/data/gold_seed.json` | `usdPerOz` 3382 · 2026-07 参考 spot |

**发版前检查**：更新 seed 后跑 `flutter test`，真机 Board/Convert/Gold 目测一轮。

---

## 5. 节流与配额

- 自动 sync：**15 分钟** 最小间隔（`RatesRepository._minSyncInterval`）
- 用户 **Sync now** / 改基准币 / 改收藏：`force: true` 绕过节流
- Frankfurter：无 Key，日频 ECB，适合 MVP
- Gold：V1 不调用 GoldAPI，无配额压力

---

## 6. 测试覆盖

| 测试文件 | 场景 |
|----------|------|
| `test/fx_fallback_test.dart` | USD → AED rebase |
| `test/rates_repository_test.dart` | USD 降级、失败 seed merge、零值 PHP 修复 |
| `test/conversion_service_test.dart` | 交叉换算 |

---

## 7. D15 前提

- [x] API 降级链
- [x] Seed 2026-07-04 更新
- [x] 失败时 seed merge 不丢换算
- [ ] Release 签名 AAB（D15）

**D14 sign-off**：稳定性缓冲完成，可进入 **D15 Production 提审**。
