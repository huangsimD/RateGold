# RateGold — D12 Internal Testing（Google Play 内测轨道）

**Package**: `com.rategold.app`  
**Version**: 1.0.0 (1)  
**Privacy URL**: https://privacy-two-pi.vercel.app/

---

## 1. 构建 AAB

```powershell
# 内测包（当前 release 使用 debug 签名，仅用于 internal track 验证）
Set-Location e:\AProject\Goto
flutter build appbundle --release
```

产出路径：

```
build/app/outputs/bundle/release/app-release.aab
```

或使用脚本：

```powershell
powershell -File tool/build_internal_aab.ps1
```

> **上架前**：在 `android/app/build.gradle.kts` 配置 release keystore，勿长期使用 debug 签名。

---

## 2. Play Console — 创建 Internal testing

1. 打开 [Google Play Console](https://play.google.com/console) → 选择 **RateGold**
2. **Testing → Internal testing** → **Create new release**
3. Upload `app-release.aab`
4. Release name: `1.0.0-internal-1`
5. Release notes（示例）:

```
Internal build for SEA/ME offline FX + gold board QA.
- Board / Convert / Settings / Gold markets
- Offline cache + sync status
- Privacy policy in-app WebView
```

6. **Review release** → **Start rollout to Internal testing**

---

## 3. 测试人员

1. **Internal testing → Testers** → Create email list
2. 添加你的 Gmail + 团队邮箱（最多 100 人）
3. 复制 **opt-in URL** 发给测试者
4. 测试者在链接中接受邀请 → Play 商店安装

---

## 4. 内测验证清单（与 D11 对齐）

- [ ] 从 Play 安装（非 sideload APK）
- [ ] 首次启动：Online sync 或 seed 显示
- [ ] 飞行模式冷启动：Offline banner
- [ ] Privacy policy 应用内打开
- [ ] 免责声明弹窗可读
- [ ] 截图与商店素材 UI 一致

---

## 5. Store listing 前置（可并行）

| 项 | 状态 |
|----|------|
| App icon 512 | `store/play/icon-512.png` |
| Feature graphic | `store/play/feature-graphic-1024x500.png` |
| Screenshots ×4 | `store/play/screenshots/` |
| Privacy policy URL | https://privacy-two-pi.vercel.app/ |
| Data Safety | 见 `docs/fx-gold-board-data-safety.md` |

---

## 6. 下一里程碑（D13–D15）

| 天 | 任务 |
|----|------|
| D13 | ASO 文案 + 多地区默认币种 |
| D14 | API 降级 / seed 更新 |
| D15 | Release 签名 AAB → Production 提审 |
