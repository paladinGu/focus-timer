# NAND Flash 价格监控脚本

自动抓取 DRAMeXchange NAND Flash 价格，支持程序化交易预判。

## 功能

- 📊 自动抓取 NAND Flash 颗粒价格
- 📈 技术指标分析 (MA/RSI/波动率)
- 🔮 程序化交易预判 (金叉/死叉/RSI超买超卖)
- 🇺🇸🇨🇳 美股/A股存储芯片股票关联
- 📱 QQ 每日定时推送
- 🏖️ 自动跳过节假日数据

## 使用方法

```bash
# 安装依赖
pip install requests

# 手动运行
python3 nand_price_monitor.py

# 设置定时任务 (每天8点)
crontab -e
0 8 * * * cd /path/to && python3 nand_price_monitor.py
```

## 监控的股票

### 美股
- MU (美光科技) - 存储芯片
- WDC (西部数据) - 存储设备
- NVDA (英伟达) - AI/GPU

### A股
- 603986.SZ (兆易创新) - 存储芯片
- 688981.SS (中芯国际) - 晶圆代工
- 002049.SZ (紫光国微) - 存储芯片
- 002371.SZ (北方华创) - 半导体设备
- 600745.SS (闻泰科技) - 功率半导体

## 报告示例

```
📊 NAND Flash + 存储芯片监控 - 2026-02-16

🔮 【程序化交易预判】
├─────────────────────────────────────┤
│  🟢 潜在买入 512Gb TLC              │
│     置信度: 中等 | 1-2天内           │
│     💡 MA5接近上穿MA10             │
└─────────────────────────────────────┘
```

## 文件说明

| 文件 | 说明 |
|------|------|
| `nand_price_monitor.py` | 主脚本 |
| `nand_price_history.json` | 价格历史数据 |
| `stock_watchlist.json` | 股票数据历史 |

## License

MIT
