

# RateGold — Google Play ASO Pack (D13)

**Product**: RateGold (`com.rategold.app`)  
**Markets**: SEA · South Asia · Gulf (PH, ID, IN, BD, MY, SG, AE, SA, PK, NP, LK, TH)  
**Date**: 2026-07-04  
**Status**: Ready for Play Console paste  

---

## 1. 默认英文主 listing（全球）

### App name（≤30 字符）

```
RateGold — FX & Gold Offline
```

（27 字符 · 含 Rate + Gold ASO 词根）

### Short description（≤80 字符）

```
Offline FX rates & gold prices. Convert remittance currencies in one tap.
```

（78 字符）

### Full description

```
RateGold shows exchange rates and local gold prices on one board—works offline after sync. No account. No ads. Built for remittance, travel, and gold shopping in Southeast Asia, India, and the Gulf.

WHY RATEGOLD
• One screen: FX rates + gold prices (INR/10g, AED/g, PHP/g, SAR/g, IDR/g)
• Offline-first: last synced rates stay readable with a clear “as of” timestamp
• Fast convert: amount in → result out, swap currencies in one tap
• Privacy-friendly: no login, data stays on your device
• Lightweight: open, check, close—no bloated finance app

FEATURES
• Board: sync status, gold strip, favorite currency rates
• Convert: cross-rate calculator with copy result
• Settings: base currency, up to 8 favorites, manual sync
• Languages: English, Chinese, Hindi, Arabic, Indonesian, Tagalog

GOLD MARKETS
India (₹/10g) · UAE & Saudi (per gram) · Philippines · Indonesia · more

DATA SOURCES
Exchange rates from Frankfurter (ECB daily). Gold spot from bundled reference price, updated when you sync. Indicative only—not a bank or remittance quote.

PERFECT FOR
• OFWs sending money home (AED→PHP, SAR→INR, etc.)
• Gold buyers checking 24K reference before visiting a shop
• Travelers and shoppers who need rates without stable data

Download RateGold—rates & gold, offline when it matters.

Disclaimer: Rates and gold prices are indicative only, sourced from public data. Not financial advice or a remittance quote.
```

---



## 2. 关键词策略（Store 无独立 keyword 字段，写入描述自然覆盖）


| 主题  | 英文词 / 短语                                                           |
| --- | ------------------------------------------------------------------ |
| 核心  | exchange rate, currency converter, offline rates, gold price today |
| 海湾  | UAE gold rate, AED to PHP, remittance rate, Dubai exchange rate    |
| 印度  | India gold price 24k, gold rate today, INR gold 10 gram            |
| 菲律宾 | PHP USD rate, peso dollar, OFW remittance                          |
| 印尼  | IDR exchange rate, rupiah dollar, kurs dolar                       |
| 离线  | offline currency, offline gold price, no internet exchange rate    |


**避免**：live trading, forex signals, investment, guaranteed profit

---



## 3. 分地区 Custom store listing

Play Console → **Store presence → Custom store listings**  
为下列国家创建英文 listing（V1 UI 以英文为主；本地语言可 V1.1 再加）。


| 国家          | 标题微调（可选） | Short description 侧重                                   | Full description 首句替换                                                          |
| ----------- | -------- | ------------------------------------------------------ | ------------------------------------------------------------------------------ |
| **阿联酋 AE**  | 同上       | AED rates & UAE gold per gram. Offline FX for expats.  | See AED, PHP, INR rates and UAE gold per gram on one board—offline after sync. |
| **沙特 SA**   | 同上       | SAR gold & remittance rates offline.                   | SAR gold per gram plus remittance rates for workers in the Gulf.               |
| **菲律宾 PH**  | 同上       | PHP peso rates & gold. OFW-friendly offline converter. | PHP peso rates and gold prices for OFWs—convert USD, AED, SAR offline.         |
| **印尼 ID**   | 同上       | IDR rupiah rates & gold offline.                       | Rupiah exchange rates and gold reference for remittance and shopping.          |
| **印度 IN**   | 同上       | 24K gold ₹/10g & FX rates offline.                     | India 24K gold in ₹/10g plus AED/USD rates on one offline board.               |
| **孟加拉 BD**  | 同上       | BDT taka rates for Gulf workers offline.               | BDT rates and Gulf remittance currencies offline after sync.                   |
| **马来西亚 MY** | 同上       | MYR ringgit & gold rates offline.                      | Ringgit rates and regional gold reference in one lightweight app.              |




### 菲律宾 Custom listing — Full description 首段（可复制）

```
RateGold shows peso exchange rates and gold prices on one board—works offline after sync. Built for OFWs: PHP, USD, AED, SAR in one tap. No account. No ads.
```



### 印度 Custom listing — Full description 首段

```
RateGold shows 24K gold in ₹/10g and exchange rates on one board—works offline after sync. Check AED and USD rates before remittance or gold shopping. No account. No ads.
```



### 阿联酋 Custom listing — Full description 首段

```
RateGold shows AED rates and UAE gold per gram on one board—works offline after sync. Convert AED→PHP, AED→INR for remittance. No account. No ads.
```

---



## 4. 截图说明文案（Play 可选 / 素材备注）


| 文件                    | 建议 caption（英文）                    |
| --------------------- | --------------------------------- |
| `01_board.png`        | Rates & gold on one board         |
| `02_convert.png`      | Convert remittance in one tap     |
| `03_settings.png`     | Your base currency & favorites    |
| `04_gold_markets.png` | Local gold units: INR/10g, AED/g… |


Feature graphic 标语（已在素材中）：

```
Rates & gold. Offline when it matters.
```

---



## 5. 分类与标签


| 字段             | 建议值                                                                      |
| -------------- | ------------------------------------------------------------------------ |
| Category       | Finance                                                                  |
| Tags（如可用）      | currency, exchange rate, gold, offline, converter                        |
| Content rating | Everyone / 金融类问卷按无用户生成内容填写                                               |
| Contact email  | 与 Play Console 开发者联系邮箱一致                                                 |
| Privacy policy | [https://privacy-two-pi.vercel.app/](https://privacy-two-pi.vercel.app/) |


---



## 6. 与应用内多地区默认币种对齐

首次安装按 **设备地区** 自动设置基准货币与收藏（见 `lib/data/region_currency_profile.dart`）：


| 地区          | 基准货币 | 默认换算    | 收藏侧重      |
| ----------- | ---- | ------- | --------- |
| AE          | AED  | AED→PHP | 汇款菲律宾/印度  |
| SA          | SAR  | SAR→PHP | 海湾劳工      |
| PH          | PHP  | PHP→USD | OFW       |
| ID          | IDR  | IDR→USD | 印尼汇款      |
| IN          | INR  | INR→USD | 金价 + 海湾汇款 |
| BD/PK/NP/LK | 本地币  | →AED    | 南亚外劳      |
| MY/SG/TH    | 本地币  | →USD    | 区域旅行/汇款   |
| CN          | CNY  | CNY→USD | 华人用户      |
| 其他          | USD  | AED→PHP | 全球默认      |


用户可在 Settings 随时修改；仅 **首次启动** 写入，不覆盖已有偏好。

---



## 7. 提审前 ASO 检查清单

- [ ] 标题 ≤30 字符，无全大写堆砌
- [ ] 短描述 ≤80 字符，含 offline + gold + convert
- [ ] 长描述末尾含免责声明
- [ ] 截图 4 张 + Feature Graphic 1024×500 + Icon 512
- [ ] AE / PH / IN 至少 3 个 Custom listing 已创建
- [ ] 隐私政策 URL 可访问
- [ ] 描述中不写 “real-time guaranteed”

---



## 8. 相关文档


| 文档                              | 用途              |
| ------------------------------- | --------------- |
| `fx-gold-board-brand-system.md` | 品牌色、Voice、基础商店句 |
| `fx-gold-board-store-assets.md` | 图标/截图 AI prompt |
| `fx-gold-board-data-safety.md`  | Data Safety 表单  |
| `store/play/`                   | 已导出 PNG 素材      |


**D13 sign-off**: ASO 文案包 + 多地区默认币种已实现，可进入 D14（API 降级 / seed 更新）。