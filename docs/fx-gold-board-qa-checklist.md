# RateGold — D11 QA Checklist（性能 / 离线）

**Device ref**: VOG AL10 · 360×800+ · Android 10  
**Build**: debug / release AAB  
**Date**: 2026-07-04

---

## 1. 自动化（CI / 本地）

```bash
flutter test
flutter analyze
```

| 套件 | 覆盖 |
|------|------|
| `rates_repository_test` | seed 加载、sync 成功/失败、**离线读缓存**、15min 节流 |
| `conversion_service_test` | 交叉汇率换算 |
| `gold_calculator_test` | 五市场金价单位 |
| `sync_status_test` | stale / offline 文案 |
| `locale_test` | 五语言 + CNY |

---

## 2. 离线场景（真机手测）

| # | 步骤 | 期望 |
|---|------|------|
| O1 | 联网打开 App → 等 Board 加载完成 | Online 状态条 · 汇率+金价有数 |
| O2 | 开飞行模式 → 杀进程 → 再开 App | **Offline** 状态条 · 仍显示上次缓存 |
| O3 | 离线时 Convert 输入金额 | 仍能换算（基于缓存 FX） |
| O4 | 离线点 Sync now | Snackbar「离线 · 显示已保存汇率」 |
| O5 | 恢复网络 → Sync now | Online · 汇率更新 |
| O6 | 连续 Sync now 两次 | 第二次提示 15min 节流（若间隔 <15min） |

---

## 3. 性能 / 稳定性

| # | 场景 | 期望 |
|---|------|------|
| P1 | 冷启动到 Board 可交互 | ≤ 3s（真机 mid-range） |
| P2 | 切换 Board / Convert / Settings | 无卡顿、无白屏 |
| P3 | 语言切换 ×5 | 不崩溃、导航正常 |
| P4 | Settings → Privacy policy | **应用内 WebView** 加载 Vercel 页 |
| P5 | Settings → 数据来源弹窗 | **深字 on 浅底**，可读 |
| P6 | Board → See all → Gold markets | 列表 5 市场 + 返回 |
| P7 | Manage favorites 拖拽排序 | 保存后 Board 顺序更新 |

---

## 4. 已知限制（V1 接受）

- Frankfurter 无 CNY 时依赖 seed/缓存
- 金价 seed 可能 stale（琥珀提示）
- Release 暂用 debug 签名（内测 OK；上架前换 release keystore）

---

## 5. Bug 记录

| ID | 描述 | 状态 |
|----|------|------|
| B1 | 隐私政策跳转外部浏览器 | ✅ 改 WebView |
| B2 | 免责声明弹窗白底白字 | ✅ dialogTheme + 显式色 |
