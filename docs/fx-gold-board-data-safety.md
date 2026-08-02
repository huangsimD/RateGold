# RateGold — Google Play Data Safety 填写指南

**App**: RateGold · `com.rategold.app` · v1.0.0  
**Privacy policy URL（已部署）**: https://privacy-two-pi.vercel.app/  
**Local file**: `docs/privacy/index.html` · 重部署见 `docs/privacy/README.md`

---

## 1. 总览结论（V1.0）

| 问题 | 建议答案 |
|------|----------|
| 是否收集/共享用户数据？ | **否** — 无账号、无广告/分析 SDK、无后端 |
| 是否仅设备端处理？ | **是** — 语言/收藏/缓存仅存本地 |
| 是否加密传输？ | **是** — Frankfurter、Google Fonts 均 HTTPS |
| 用户能否请求删除？ | **是** — 卸载或清除应用数据即可 |

> Play Console 路径：**App content → Data safety**

---

## 2. Step-by-step（Play Console 2025 向导）

### 2.1 Does your app collect or share any of the required user data types?

**选择：No**

依据：
- 不收集姓名、邮箱、位置、财务账户等 Play 定义的 user data types
- `shared_preferences` / 本地 JSON 缓存 **不上传** 到开发者服务器
- 无 Firebase Analytics、Crashlytics、AdMob 等 SDK

### 2.2 Is all of the user data collected by your app encrypted in transit?

**选择：Yes**（若上一题选 No，此题通常跳过）

说明：同步时仅 HTTPS 请求 Frankfurter；字体走 Google Fonts CDN（HTTPS）。

### 2.3 Do you provide a way for users to request that their data is deleted?

**选择：Yes**

说明文案（英文，可粘贴到 Play 说明框）：

> Users can delete all app data by clearing storage in Android Settings or uninstalling the app. We operate no cloud account or server-side profile for RateGold v1.0.

### 2.4 Independent security review

**选择：No**（V1  indie 工具类应用通常不需要）

---

## 3. Data types 明细（若 Play 要求逐项确认）

对以下类型一律选 **Not collected / Not shared**：

| Data type | RateGold V1 |
|-----------|-------------|
| Location | ❌ 不请求权限 |
| Personal info (name, email, etc.) | ❌ |
| Financial info (user accounts) | ❌ 仅展示公开牌价，不收集用户资产 |
| Health / Fitness | ❌ |
| Messages | ❌ |
| Photos / Videos | ❌ |
| Audio files | ❌ |
| Files and docs (user uploads) | ❌ |
| Calendar | ❌ |
| Contacts | ❌ |
| App activity (analytics) | ❌ 无分析 SDK |
| Web browsing | ❌ |
| App info and performance (crash logs to 3rd party) | ❌ |
| Device or other IDs (advertising ID) | ❌ 不读取 GAID |

### 第三方网络说明（写在 Privacy Policy，不必在 Data Safety 标为 “collected”）

| 服务 | 发送内容 | 用途 |
|------|----------|------|
| Frankfurter API | 货币代码 query（如 `from=USD&to=PHP`） | 拉公开汇率 |
| Google Fonts CDN | 标准 HTTP 连接（IP 等由 Google 处理） | 加载 Inter 字体 |

---

## 4. 与 Privacy Policy 对齐检查

- [ ] Play 列表中的 **Privacy policy URL** 可公开访问
- [ ] URL 内容与 `docs/privacy/index.html` 一致
- [ ] 应用内 **Settings → Privacy policy** 指向同一 URL
- [ ] 联系邮箱已替换占位符 `support@rategold.app`
- [ ] 商店完整描述含金融免责声明（见 PRD §7.3）

---

## 5. 商店文案 — 免责声明（英文，可贴 Full description 末尾）

```
Disclaimer: Exchange rates and gold prices are indicative only. Not investment advice, bank quotes, or remittance rates. Confirm with your bank or jeweller before transacting.
```

---

## 6. GitHub Pages 部署（可选）

1. Repo → **Settings → Pages**
2. Source: Deploy from branch `main`, folder `/docs`
3. 隐私政策地址：`https://privacy-two-pi.vercel.app/`（Vercel 项目 `privacy`）
4. 构建发布时可选传入（默认已对齐）：

```bash
flutter build apk --dart-define=PRIVACY_POLICY_URL=https://privacy-two-pi.vercel.app/
```

---

## 7. 若审核追问

**Q: 应用联网做什么？**  
A: 仅拉公开 FX 数据（Frankfurter）与 UI 字体（Google Fonts）。无用户注册，无数据回传开发者服务器。

**Q: 本地存什么？**  
A: 语言、基准货币、收藏列表、汇率/金价缓存 JSON — 均在设备沙箱内。

**Q: 以后 V1.1 订阅怎么办？**  
A: 启用 Play Billing 后需 **更新** Data Safety（购买历史由 Google Play 处理，仍不建自有账号体系则变更较小）。
