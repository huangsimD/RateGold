# RateGold — Ops 运营后台（Closed testing 先行）

**目标版本**：`1.1.0+3`（仅测试轨道）  
**线上正式版**：继续使用已上架的 `1.0.0+2`（无埋点），直到主动放开  
**功能清单**：见 [`docs/下版本上线功能点-1.1.0.md`](./下版本上线功能点-1.1.0.md)

---

## 0. 正式服（已部署）

| 项 | 值 |
|----|-----|
| **Ops 后台** | https://rategold-ops.vercel.app/ |
| Health | https://rategold-ops.vercel.app/health |
| 代码仓库 | https://github.com/huangsimD/RateGold |
| 托管 | Vercel 项目 `rategold-ops` |
| 数据 | GitHub **私有 Gist**（`OPS_GIST_ID` + `OPS_GITHUB_TOKEN`） |

Closed testing 打包（默认已指向正式 URL）：

```powershell
powershell -File tool/build_ops_test_aab.ps1
```

`OPS_INGEST_TOKEN` 须与 Vercel 环境变量一致（本机可写在 `ops/.env`，勿提交）。

---

## 1. 本机启动 Ops

```powershell
cd e:\AProject\Goto\ops
copy .env.example .env   # 首次
npm install
npm start
```

- 管理页：http://127.0.0.1:8788/（浏览器会提示 Basic Auth）
- 默认账号：`.env` 中 `OPS_ADMIN_USER` / `OPS_ADMIN_PASS`
- 上报 token：`OPS_INGEST_TOKEN`
- 数据文件：`ops/data/ops.json`（无 better-sqlite3 原生编译，便于 Windows）

真机联调时，手机访问的是电脑局域网 IP，不能用 `127.0.0.1`。

---

## 2. 打测试包（含埋点）

```powershell
cd e:\AProject\Goto
powershell -File tool/build_ops_test_aab.ps1 -OpsBaseUrl "http://192.168.x.x:8788"
```

产出：`build/app/outputs/bundle/release/app-release.aab`  
版本强制为 **1.1.0+3**，并注入 `OPS_BASE_URL` / `OPS_INGEST_TOKEN`。

上传路径：**Play Console → Testing → Closed testing**（勿传 Production）。

---



## 3. 正式包（无埋点，不影响线上策略）

```powershell
powershell -File tool/build_release_aab.ps1
```

不传任何 `OPS_*` dart-define → `OpsAnalytics` 全部 no-op。

---



## 4. App 埋点开关


| Define             | 作用                |
| ------------------ | ----------------- |
| `OPS_BASE_URL`     | 非空才上报；正式包留空       |
| `OPS_INGEST_TOKEN` | 请求头 `X-Ops-Token` |
| `OPS_APP_VERSION`  | 可选，覆盖上报的版本字符串     |


事件：`first_open` / `app_open` / `screen_view`（board / convert / settings / gold / favorites / privacy）。

---

## 5. Data Safety / 隐私门槛（正式上架含埋点前）

当前商店声明为 **不收集用户数据、无 analytics**。  
在把带埋点的包推到 **Production** 之前必须：

1. 更新 Play **Data safety**
2. 更新隐私政策页
3. 同步 [`docs/fx-gold-board-data-safety.md`](./fx-gold-board-data-safety.md)

Closed testing 期间可暂不改商店声明，但仅限白名单测试员。

---

## 6. 看板指标（App 埋点）

- 总用户数、今天新增、今天浏览（screen_view）
- DAU / WAU、留存 D1 / D7、近 7 日趋势
- 用户列表：install_id、首末活跃、打开次数、最近屏幕、版本、语言

---

## 7. Play 商店页（安装 / 活跃）

后台**默认不会**自动同步 Play Console；现网 `1.0.0+2` 也无 App 埋点。  
侧栏 **Play 商店** 用于查看 Play 侧安装/活跃，**不要求更 App 包**：

1. **手动 CSV（立即可用）**  
   Play Console → 统计信息 → 抄写/导出每日数据，粘贴后点「保存快照」。  
   表头：`date,installs,uninstalls,active_device_installs,dau`

2. **Reporting API（可选）**  
   - Cloud 启用 Google Play Developer Reporting API  
   - 服务账号 JSON → Vercel：`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`  
   - Play Console 邀请该服务账号  
   - 页面点「从 Play API 刷新」

接口：`GET /v1/play-console` · `POST /v1/play-console/snapshot` · `GET /v1/play-console?refresh=1`

