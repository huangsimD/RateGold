# RateGold Ops（运营后台）

匿名埋点接收 + 分析看板 / 用户列表。供 **Closed testing** 验证；正式包默认不连此服务。

**正式服**：https://rategold-ops.vercel.app/  
**仓库**：https://github.com/huangsimD/RateGold  

存储：本地 JSON（`data/ops.json`）；生产环境用 GitHub 私有 Gist（无原生编译依赖）。

## 本机启动

```powershell
cd e:\AProject\Goto\ops
copy .env.example .env
npm install
npm start
```

- 管理页：http://127.0.0.1:8788/
- 健康检查：http://127.0.0.1:8788/health
- 默认账号见 `.env`：`OPS_ADMIN_USER` / `OPS_ADMIN_PASS`
- App 上报需带 header：`X-Ops-Token: <OPS_INGEST_TOKEN>`

## API

| 方法 | 路径 | 鉴权 |
|------|------|------|
| POST | `/v1/events` | `X-Ops-Token`（若配置了 token） |
| GET | `/v1/dashboard` | Basic Auth |
| GET | `/v1/users?limit=&offset=&q=` | Basic Auth |

事件体示例：

```json
{
  "install_id": "uuid",
  "event": "screen_view",
  "screen": "board",
  "app_version": "1.1.0+3",
  "locale": "en",
  "ts": "2026-08-02T03:00:00.000Z"
}
```

也可 `{ "events": [ ... ] }`（最多 50 条）。

## 与 App 联调

测试 AAB 构建见仓库根目录：

```powershell
powershell -File tool/build_ops_test_aab.ps1 -OpsBaseUrl "http://10.x.x.x:8788"
```

真机访问本机 ops 时，`OPS_BASE_URL` 须为局域网 IP，不能用 `127.0.0.1`。
