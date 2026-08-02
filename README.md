# RateGold

Offline FX rates & local gold prices — Flutter Android app (`com.rategold.app`).

**GitHub**: [huangsimD/RateGold](https://github.com/huangsimD/RateGold)

## Production Ops (运营后台)

| 项 | 链接 / 说明 |
|----|-------------|
| **正式服后台** | https://rategold-ops.vercel.app/ |
| Health | https://rategold-ops.vercel.app/health |
| 代码目录 | [`ops/`](ops/) |
| 部署说明 | [`docs/fx-gold-board-ops.md`](docs/fx-gold-board-ops.md) |
| Play 安装/活跃 | 后台侧栏 **Play 商店**（手动 CSV 或 Reporting API） |
| 版本迭代计划 | [`Version Plan/`](Version%20Plan/README.md) · 当前 [`v1.1.0`](Version%20Plan/v1.1.0.md) |

管理页需 Basic Auth（账号见 Vercel 项目环境变量 `OPS_ADMIN_*`，勿提交到仓库）。

数据持久化：GitHub **私有 Gist**（不写进公开仓库）。

## App 构建

```powershell
# 正式包（无埋点，不影响现网策略）
powershell -File tool/build_release_aab.ps1

# Closed testing 包（连正式 Ops）
powershell -File tool/build_ops_test_aab.ps1 -OpsBaseUrl "https://rategold-ops.vercel.app"
```

## 本地 Ops

```powershell
cd ops
copy .env.example .env
npm install
npm start
```
