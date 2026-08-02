# RateGold — D15 Production 提审清单

**Package**: `com.rategold.app`  
**Version**: 1.0.0 (1)  
**Privacy**: [https://privacy-two-pi.vercel.app/](https://privacy-two-pi.vercel.app/)  
**ASO**: `docs/fx-gold-board-aso.md`  
**Data Safety**: `docs/fx-gold-board-data-safety.md`

---

## 1. Release 签名（一次性）

```powershell
cd e:\AProject\Goto

# 生成 upload keystore + android/key.properties（仅首次）
powershell -File tool/create_release_keystore.ps1

# 或手动：复制 android/key.properties.example → android/key.properties 并填写
```

**务必离线备份**：

- `android/keystore/rategold-upload.jks`
- store / key 密码
- `key.properties` 内容



> Play App Signing 启用后，Google 持有 app signing key；你上传的是 **upload key**。丢失 upload key 可在 Play Console 重置，但首次务必备份。

---



## 2. 构建 Production AAB

```powershell
powershell -File tool/build_release_aab.ps1
```

脚本会：`flutter test` → `flutter build appbundle --release` → 输出 SHA-256。

产出：

```
build/app/outputs/bundle/release/app-release.aab
```

内测仍可用（debug 签名）：

```powershell
powershell -File tool/build_internal_aab.ps1
# 或 build_release_aab.ps1 -AllowDebugSigning
```

---



## 3. Play Console — Store listing


| 字段                   | 值 / 路径                                                                   |
| -------------------- | ------------------------------------------------------------------------ |
| App name             | `RateGold — FX & Gold Offline`                                           |
| Short description    | 见 `store/play/listing-en.md`                                             |
| Full description     | 见 `docs/fx-gold-board-aso.md` §1                                         |
| App icon 512         | `store/play/icon-512.png`                                                |
| Feature graphic      | `store/play/feature-graphic-1024x500.png`                                |
| Phone screenshots ×4 | `store/play/screenshots/01_board.png` … `04_gold_markets.png`            |
| Category             | Finance                                                                  |
| Privacy policy URL   | [https://privacy-two-pi.vercel.app/](https://privacy-two-pi.vercel.app/) |
| Contact email        | 开发者联系邮箱                                                                  |


**Custom listings（建议）**：AE · PH · IN — 文案见 `docs/fx-gold-board-aso.md` §3。

---



## 4. Data Safety & 政策


| 项     | 填写要点                 |
| ----- | -------------------- |
| 数据收集  | **否** — 不收集个人/财务账户数据 |
| 数据共享  | **否**                |
| 加密传输  | 是（HTTPS 拉公开牌价）       |
| 数据删除  | 用户卸载即清除本地缓存          |
| 金融类问卷 | 工具/参考汇率，非银行、非汇款服务    |


逐步对照：`docs/fx-gold-board-data-safety.md`。

---



## 5. Content rating

1. Play Console → **Policy → App content → Content rating**
2. 问卷选 **Utility / Reference** 类金融工具
3. 无 UGC、无赌博、无暴力
4. 保存 IARC 评级 PDF

---



## 6. Production release 步骤

1. **Release → Production** → **Create new release**
2. Upload `app-release.aab`（**必须**为 release 签名，非 debug）
3. Release name: `1.0.0`
4. Release notes（示例）:

```
Initial release — offline FX rates and local gold prices on one board.
• Board, Convert, Settings, Gold markets
• Offline cache with honest sync status
• Regional default currencies
• Privacy policy in-app
```

1. **Review release** → 解决所有 **Policy / Errors** 阻断项
2. **Start rollout to Production**（建议 **Staged rollout 20%** 首日，观察崩溃与评分）

---



## 7. 提审前自检（P0）

- [ ] `android/key.properties` 存在，AAB 非 debug 签名
- [ ] `flutter test` 全绿（build 脚本已跑）
- [ ] 真机：Online / Offline / Sync failed 三态
- [ ] AED→PHP 换算可用
- [ ] 隐私政策页应用内可打开
- [ ] 免责声明可读（非白字）
- [ ] 商店截图与当前 UI 一致
- [ ] version `1.0.0+1` 与 Play 首次版本一致

---



## 8. 常见拒审 / 阻断


| 问题                       | 处理                                      |
| ------------------------ | --------------------------------------- |
| 使用 debug 签名上传 Production | 配置 `key.properties` 后重新 build           |
| 隐私政策 URL 404             | 确认 Vercel 部署可访问                         |
| 金融类误导                    | 描述与 App 内免责声明一致，不写 real-time guaranteed |
| Data Safety 与行为不符        | 仅声明网络拉公开 API + 本地存储                     |


---



## 9. 发布后 48h

- Play Console → **Android vitals** 看崩溃率
- **User feedback** / 评分
- 目标：崩溃率 < 1%，无 P0 汇率/离线 bug

---



## 10. 里程碑


| 天                        | 状态                                 |
| ------------------------ | ---------------------------------- |
| D13 ASO + 地区默认           | ✅                                  |
| D14 API 降级 + seed        | ✅                                  |
| **D15 Release AAB + 提审** | 本文档 + `tool/build_release_aab.ps1` |


**D15 sign-off**：签名配置就绪、AAB 脚本就绪；你在 Play Console 上传并点 rollout 即完成 MVP 上架。