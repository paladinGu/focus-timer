#!/usr/bin/env python3
"""
NAND Flash 价格 + 存储芯片股票监控
自动抓取数据并通过 QQ 推送
支持：价格变化分析、趋势图表、价格预警、买卖信号、程序化交易预判
"""

import subprocess
import json
import re
import os
import math
from datetime import datetime
from urllib.request import urlopen, Request
import urllib.error

# 配置文件
CONFIG = {
    "user_id": "8D5D2BE2D07388E63C9F05EACA14FC3D",
    "channel": "qqbot",
    "data_file": "/root/.openclaw/workspace/nand_price_history.json",
    "stock_file": "/root/.openclaw/workspace/stock_watchlist.json",
    "alert_threshold": 3.0,  # 价格变动预警阈值
    "volatility_threshold": 2.0,  # 波动率预警阈值
    "rsi_overbought": 70,  # RSI超买阈值
    "rsi_oversold": 30,    # RSI超卖阈值
    "stocks": {
        # 美股
        "MU": {"name": "美光科技", "country": "US", "sector": "存储芯片"},
        "WDC": {"name": "西部数据", "country": "US", "sector": "存储设备"},
        "NVDA": {"name": "英伟达", "country": "US", "sector": "AI/GPU"},
        # A股 (存储/半导体相关)
        "603986.SZ": {"name": "兆易创新", "country": "CN", "sector": "存储芯片"},
        "688981.SS": {"name": "中芯国际", "country": "CN", "sector": "晶圆代工"},
        "002049.SZ": {"name": "紫光国微", "country": "CN", "sector": "存储芯片"},
        "002371.SZ": {"name": "北方华创", "country": "CN", "sector": "半导体设备"},
        "600745.SS": {"name": "闻泰科技", "country": "CN", "sector": "功率半导体"},
    }
}

DATA_FILE = CONFIG["data_file"]
STOCK_FILE = CONFIG["stock_file"]

# ============ 基础函数 ============

def fetch_nand_price():
    """抓取 DRAMeXchange NAND Flash 价格"""
    print(f"[{datetime.now()}] 正在抓取 DRAMeXchange...")
    
    try:
        req = Request(
            "https://www.dramexchange.com/",
            headers={'User-Agent': 'Mozilla/5.0'}
        )
        with urlopen(req, timeout=30) as response:
            return response.read().decode('utf-8')
    except urllib.error.URLError as e:
        print(f"抓取错误: {e}")
        return ""

def parse_nand_price(html_content):
    """解析 NAND Flash 价格"""
    prices = {
        "date": datetime.now().strftime("%Y-%m-%d"),
        "update_time": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "items": []
    }
    
    try:
        patterns = [
            (r'512Gb TLC.*?tab_tr_gray">(\d+\.?\d*)</td>', '512Gb TLC'),
            (r'256Gb TLC.*?tab_tr_gray">(\d+\.?\d*)</td>', '256Gb TLC'),
            (r'128Gb TLC.*?tab_tr_gray">(\d+\.?\d*)</td>', '128Gb TLC'),
            (r'MLC 64Gb.*?tab_tr_gray">(\d+\.?\d*)</td>', '64Gb MLC'),
            (r'MLC 32Gb.*?tab_tr_gray">(\d+\.?\d*)</td>', '32Gb MLC'),
            (r'SLC 2Gb.*?tab_tr_gray">(\d+\.?\d*)</td>', 'SLC 2Gb'),
        ]
        
        for pattern, name in patterns:
            matches = re.findall(pattern, html_content, re.DOTALL)
            if matches:
                prices["items"].append({
                    "name": name,
                    "price": float(matches[0])
                })
    except Exception as e:
        print(f"解析错误: {e}")
    
    return prices

# ============ 股票部分 ============

def fetch_stock_price(ticker):
    """获取股票价格"""
    return {"price": None, "change": None, "note": "API受限"}

def get_stock_data():
    """获取股票数据"""
    stocks = []
    
    stock_list = [
        # 美股
        {"ticker": "MU", "name": "美光科技", "country": "US", "sector": "存储芯片"},
        {"ticker": "WDC", "name": "西部数据", "country": "US", "sector": "存储设备"},
        {"ticker": "NVDA", "name": "英伟达", "country": "US", "sector": "AI/GPU"},
        # A股
        {"ticker": "603986.SZ", "name": "兆易创新", "country": "CN", "sector": "存储芯片"},
        {"ticker": "688981.SS", "name": "中芯国际", "country": "CN", "sector": "晶圆代工"},
        {"ticker": "002049.SZ", "name": "紫光国微", "country": "CN", "sector": "存储芯片"},
        {"ticker": "002371.SZ", "name": "北方华创", "country": "CN", "sector": "半导体设备"},
        {"ticker": "600745.SS", "name": "闻泰科技", "country": "CN", "sector": "功率半导体"},
    ]
    
    for stock in stock_list:
        data = fetch_stock_price(stock["ticker"])
        stocks.append({
            "ticker": stock["ticker"],
            "name": stock["name"],
            "country": stock["country"],
            "sector": stock["sector"],
            "price": data.get("price"),
            "change": data.get("change"),
            "note": data.get("note", "")
        })
    
    return stocks

def load_stock_history():
    """加载股票历史"""
    if os.path.exists(STOCK_FILE):
        try:
            with open(STOCK_FILE, 'r') as f:
                return json.load(f)
        except:
            return {"records": []}
    return {"records": []}

def save_stock_data(stocks):
    """保存股票数据"""
    history = load_stock_history()
    record = {
        "date": datetime.now().strftime("%Y-%m-%d"),
        "stocks": stocks
    }
    history["records"].insert(0, record)
    history["records"] = history["records"][:30]
    
    with open(STOCK_FILE, 'w') as f:
        json.dump(history, f, indent=2)
    
    print(f"已保存股票数据 (共 {len(history['records'])} 条)")

# ============ 数据存储部分 ============

def load_history():
    """加载 NAND 历史"""
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, 'r') as f:
                return json.load(f)
        except:
            return {"records": []}
    return {"records": []}

def save_nand_data(data):
    """保存 NAND 数据"""
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f, indent=2)

def get_valid_records(history, needed_days):
    """获取有效的连续记录（跳过节假日/无数据的日期）"""
    valid_records = []
    for rec in history["records"]:
        if rec.get("items") and len(rec["items"]) > 0:
            valid_records.append(rec)
        if len(valid_records) >= needed_days:
            break
    return valid_records

def analyze_changes(current_data, history):
    """分析价格变化，包含技术指标和程序化交易预判"""
    changes = []
    alerts = []
    signals = []
    predictions = []
    
    if not history["records"]:
        return changes, alerts, signals, predictions, "首次抓取"
    
    last_record = history["records"][0]
    
    # 获取有效记录（跳过节假日）
    valid_history = {"records": get_valid_records(history, 25)}
    
    # 计算技术指标
    ma5 = calculate_ma(valid_history, 5)
    ma10 = calculate_ma(valid_history, 10)
    ma20 = calculate_ma(valid_history, 20)
    volatility = calculate_volatility(valid_history, 5)
    rsi = calculate_rsi(valid_history, 14)
    
    for curr_item in current_data["items"]:
        name = curr_item["name"]
        price = curr_item["price"]
        
        last_price = None
        for rec in last_record.get("items", []):
            if rec["name"] == name:
                last_price = rec["price"]
                break
        
        if last_price and last_price > 0:
            change_pct = ((price - last_price) / last_price) * 100
            
            changes.append({
                "name": name,
                "current": price,
                "previous": last_price,
                "change_pct": change_pct
            })
            
            # 价格预警
            if abs(change_pct) >= CONFIG["alert_threshold"]:
                alerts.append({"name": name, "change_pct": change_pct, "current": price})
            
            # 买卖信号检测
            signal = detect_trading_signal(name, price, ma5.get(name), ma10.get(name), history)
            if signal:
                signals.append(signal)
            
            # 程序化交易预判
            prediction = predict_algo_trading(name, price, ma5.get(name), ma10.get(name), 
                                              ma20.get(name), volatility.get(name), 
                                              rsi.get(name), history)
            if prediction:
                predictions.append(prediction)
    
    return changes, alerts, signals, predictions, "正常"

def calculate_ma(history, days):
    """计算移动平均线"""
    ma = {}
    if len(history["records"]) < days:
        return ma
    
    for item_name in ["512Gb TLC", "256Gb TLC", "128Gb TLC", "64Gb MLC", "32Gb MLC", "SLC 2Gb"]:
        prices = []
        for rec in history["records"][:days]:
            for item in rec.get("items", []):
                if item["name"] == item_name:
                    prices.append(item["price"])
                    break
        if len(prices) == days:
            ma[item_name] = sum(prices) / days
    
    return ma

def calculate_volatility(history, days=5):
    """计算波动率 (标准差/均值)"""
    volatility = {}
    if len(history["records"]) < days:
        return volatility
    
    for item_name in ["512Gb TLC", "256Gb TLC", "128Gb TLC", "64Gb MLC", "32Gb MLC", "SLC 2Gb"]:
        prices = []
        for rec in history["records"][:days]:
            for item in rec.get("items", []):
                if item["name"] == item_name:
                    prices.append(item["price"])
                    break
        
        if len(prices) >= 3:
            mean = sum(prices) / len(prices)
            variance = sum((p - mean) ** 2 for p in prices) / len(prices)
            std_dev = math.sqrt(variance)
            volatility[item_name] = (std_dev / mean * 100) if mean > 0 else 0
    
    return volatility

def calculate_rsi(history, periods=14):
    """计算RSI指标"""
    rsi = {}
    if len(history["records"]) < periods + 1:
        return rsi
    
    for item_name in ["512Gb TLC", "256Gb TLC", "128Gb TLC", "64Gb MLC", "32Gb MLC", "SLC 2Gb"]:
        prices = []
        for rec in history["records"][:periods + 1]:
            for item in rec.get("items", []):
                if item["name"] == item_name:
                    prices.append(item["price"])
                    break
        
        if len(prices) >= periods + 1:
            gains = []
            losses = []
            for i in range(1, len(prices)):
                change = prices[i] - prices[i-1]
                if change > 0:
                    gains.append(change)
                    losses.append(0)
                else:
                    gains.append(0)
                    losses.append(abs(change))
            
            avg_gain = sum(gains) / periods if gains else 0
            avg_loss = sum(losses) / periods if losses else 0
            
            if avg_loss == 0:
                rsi[item_name] = 100
            else:
                rs = avg_gain / avg_loss
                rsi[item_name] = 100 - (100 / (1 + rs))
    
    return rsi

def detect_trading_signal(name, current_price, ma5, ma10, history):
    """检测买卖信号"""
    if not ma5 or not ma10 or len(history["records"]) < 3:
        return None
    
    recent_changes = []
    for i in range(3):
        if i < len(history["records"]):
            for item in history["records"][i].get("items", []):
                if item["name"] == name:
                    recent_changes.append(item["price"])
                    break
    
    if len(recent_changes) < 3:
        return None
    
    # 买入信号
    if current_price < ma10 and recent_changes[0] < recent_changes[1] < recent_changes[2] < current_price:
        return {"type": "BUY", "name": name, "price": current_price, "reason": "价格触底反弹"}
    
    # 卖出信号
    if current_price > ma10 and recent_changes[0] > recent_changes[1] > recent_changes[2] > current_price:
        return {"type": "SELL", "name": name, "price": current_price, "reason": "价格触顶回落"}
    
    # 风险警示
    if ma5 and current_price > ma5 * 1.05:
        return {"type": "WARN", "name": name, "price": current_price, "reason": "价格偏离MA5超5%"}
    
    return None

def predict_algo_trading(name, current_price, ma5, ma10, ma20, volatility, rsi, history):
    """程序化交易预判 - 提前识别潜在交易行为"""
    if not all([ma5, ma10, ma20, volatility, rsi]) or len(history["records"]) < 5:
        return None
    
    predictions = []
    
    # 1. 检测MA金叉/死叉预判
    if ma5 > ma10 and ma10 <= ma20:
        predictions.append({
            "type": "GOLDEN_CROSS",
            "name": name,
            "action": "潜在买入",
            "confidence": "中等",
            "reason": "MA5接近上穿MA10，可能触发程序化买入",
            "timing": "1-2天内"
        })
    elif ma5 < ma10 and ma10 >= ma20:
        predictions.append({
            "type": "DEATH_CROSS",
            "name": name,
            "action": "潜在卖出",
            "confidence": "中等",
            "reason": "MA5接近下穿MA10，可能触发程序化卖出",
            "timing": "1-2天内"
        })
    
    # 2. RSI超买超卖预判
    if rsi > CONFIG["rsi_overbought"] - 10:
        predictions.append({
            "type": "RSI_OVERBOUGHT",
            "name": name,
            "action": "注意回调",
            "confidence": "较高",
            "reason": f"RSI={rsi:.1f}接近超买区，程序化交易可能平仓",
            "timing": "短期"
        })
    elif rsi < CONFIG["rsi_oversold"] + 10:
        predictions.append({
            "type": "RSI_OVERSOLD",
            "name": name,
            "action": "可能反弹",
            "confidence": "较高",
            "reason": f"RSI={rsi:.1f}接近超卖区，可能触发抄底",
            "timing": "短期"
        })
    
    # 3. 波动率异常预判
    if volatility > CONFIG["volatility_threshold"]:
        predictions.append({
            "type": "HIGH_VOLATILITY",
            "name": name,
            "action": "波动加剧",
            "confidence": "高",
            "reason": f"波动率={volatility:.1f}%异常升高，程序化交易可能快速进出",
            "timing": "立即"
        })
    
    # 4. 价格偏离预判
    if current_price > ma20 * 1.1:
        predictions.append({
            "type": "PRICE_HIGH",
            "name": name,
            "action": "警惕回落",
            "confidence": "中等",
            "reason": "价格高于MA20超过10%，可能有回调压力",
            "timing": "短期"
        })
    elif current_price < ma20 * 0.9:
        predictions.append({
            "type": "PRICE_LOW",
            "name": name,
            "action": "关注支撑",
            "confidence": "中等",
            "reason": "价格低于MA20超过10%，可能测试下方支撑",
            "timing": "短期"
        })
    
    # 返回最关键的预判
    if predictions:
        # 按置信度和紧急程度排序
        priority = {"HIGH_VOLATILITY": 0, "RSI_OVERBOUGHT": 1, "RSI_OVERSOLD": 2, 
                    "GOLDEN_CROSS": 3, "DEATH_CROSS": 4, "PRICE_HIGH": 5, "PRICE_LOW": 6}
        predictions.sort(key=lambda x: priority.get(x["type"], 10))
        return predictions[0]
    
    return None

# ============ 报告生成 ============

def generate_trend_chart(history, item_name, days=7):
    """生成 ASCII 趋势图表"""
    if len(history["records"]) < 2:
        return "📈 暂无足够历史数据"
    
    prices = []
    dates = []
    for rec in history["records"][:days]:
        for item in rec.get("items", []):
            if item["name"] == item_name:
                prices.append(item["price"])
                dates.append(rec["date"][-5:])
                break
    
    if len(prices) < 2:
        return f"📈 暂无 {item_name} 历史数据"
    
    min_p, max_p = min(prices), max(prices)
    range_p = max_p - min_p if max_p != min_p else 1
    
    chart = f"\n📊 {item_name} 近{len(prices)}天走势\n```\n"
    chart += f"${max_p:.2f}\n${(max_p + min_p)/2:.2f}\n${min_p:.2f}\n"
    chart += "└" + "─" * (len(prices) * 4 + 1) + "\n"
    
    for i, (price, date) in enumerate(zip(prices, dates)):
        pos = int((price - min_p) / range_p * 10)
        chart += "    " + "  " * pos + f"● ${price:.2f} ({date})\n"
    
    total = ((prices[-1] - prices[0]) / prices[0] * 100) if prices[0] > 0 else 0
    trend = "📈" if total > 0 else "📉" if total < 0 else "➡️"
    chart += f"```\n趋势: {trend} {total:+.2f}%"
    
    return chart

def generate_report(nand_data, nand_changes, nand_alerts, signals, predictions, stock_data, history):
    """生成综合报告"""
    today = datetime.now().strftime("%Y-%m-%d")
    last_date = history["records"][0]["date"] if history["records"] else "无"
    
    report = f"""📊 NAND Flash + 存储芯片监控 - {today}

🕐 抓取时间: {nand_data['update_time']}
📡 NAND数据: DRAMeXchange
📅 上次更新: {last_date}

"""
    
    # 程序化交易预判
    if predictions:
        report += "🔮 【程序化交易预判】\n"
        report += "┌─────────────────────────────────────┐\n"
        for pred in predictions:
            emoji = "🟢" if "买入" in pred["action"] or "反弹" in pred["action"] else "🔴" if "卖出" in pred["action"] or "回落" in pred["action"] else "🟡"
            report += f"│  {emoji} {pred['action']} {pred['name']:<8}            │\n"
            report += f"│     置信度: {pred['confidence']} | {pred['timing']}           │\n"
            report += f"│     💡 {pred['reason'][:28]}    │\n"
        report += "└─────────────────────────────────────┘\n\n"
    
    # 买卖信号
    if signals:
        report += "🎯 【即时买卖信号】\n"
        report += "┌─────────────────────────────────────┐\n"
        for sig in signals:
            if sig["type"] == "BUY":
                emoji = "🟢"
                action = "买入"
            elif sig["type"] == "SELL":
                emoji = "🔴"
                action = "卖出"
            else:
                emoji = "🟡"
                action = "关注"
            report += f"│  {emoji} {action} {sig['name']:<8} ${sig['price']:.2f}      │\n"
            report += f"│     💡 {sig['reason']}        │\n"
        report += "└─────────────────────────────────────┘\n\n"
    
    # 价格预警
    if nand_alerts:
        report += "🚨 【价格预警】\n"
        report += "┌─────────────────────────────────────┐\n"
        for alert in nand_alerts:
            emoji = "📈" if alert["change_pct"] > 0 else "📉"
            report += f"│  {emoji} {alert['name']:<10} {alert['change_pct']:+.1f}% (${alert['current']:.2f}) │\n"
        report += "└─────────────────────────────────────┘\n\n"
    
    # NAND 价格
    report += "┌─────────────────────────────────────┐\n"
    report += "│  📦 NAND Flash 颗粒价格 (美元)        │\n"
    report += "├─────────────────────────────────────┤\n"
    
    for item in nand_data.get("items", []):
        change = ""
        for c in nand_changes:
            if c["name"] == item["name"]:
                change = f" ({c['change_pct']:+.1f}%)"
                break
        report += f"│  {item['name']:<12} : ${item['price']:<8.3f}{change:>6} │\n"
    
    report += "└─────────────────────────────────────┘\n"
    
    # 关联股票
    us_stocks = [s for s in stock_data if s["country"] == "US"]
    cn_stocks = [s for s in stock_data if s["country"] == "CN"]
    
    if us_stocks:
        report += "\n┌─────────────────────────────────────┐\n"
        report += "│  🇺🇸 美股 - 存储芯片                  │\n"
        report += "├─────────────────────────────────────┤\n"
        for stock in us_stocks:
            if stock["price"]:
                emoji = "📈" if stock["change"] and stock["change"] > 0 else "📉" if stock["change"] and stock["change"] < 0 else "➡️"
                report += f"│  {emoji} {stock['ticker']:<6} {stock['name']:<8} ${stock['price']:.2f} {stock['change']:+.2f}% │\n"
            else:
                report += f"│  ➡️ {stock['ticker']:<6} {stock['name']:<10} (API受限) │\n"
        report += "└─────────────────────────────────────┘\n"
    
    if cn_stocks:
        report += "\n┌─────────────────────────────────────┐\n"
        report += "│  🇨🇳 A股 - 存储/半导体               │\n"
        report += "├─────────────────────────────────────┤\n"
        for stock in cn_stocks:
            if stock["price"]:
                emoji = "📈" if stock["change"] and stock["change"] > 0 else "📉" if stock["change"] and stock["change"] < 0 else "➡️"
                report += f"│  {emoji} {stock['ticker']:<10} {stock['name']:<8} ¥{stock['price']:.2f} {stock['change']:+.2f}% │\n"
            else:
                report += f"│  ➡️ {stock['ticker']:<10} {stock['name']:<10} (API受限) │\n"
        report += "└─────────────────────────────────────┘\n"
    
    report += "\n💡 股票API暂时受限，请前往以下网站查看:\n"
    report += "   • 美股: https://finance.yahoo.com\n"
    report += "   • A股: https://quote.eastmoney.com\n"
    
    # 趋势图表
    if nand_data["items"]:
        chart = generate_trend_chart(history, nand_data["items"][0]["name"])
        report += f"\n{chart}"
    
    report += f"\n\n---\n🕘 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    
    return report

def send_message(message):
    """发送 QQ 消息"""
    cmd = [
        "openclaw", "message", "send",
        "--channel", CONFIG["channel"],
        "--to", CONFIG["user_id"],
        "--message", message
    ]
    subprocess.run(cmd, capture_output=True)
    print(f"[{datetime.now()}] 消息已发送")

def main():
    """主函数"""
    print(f"[{datetime.now()}] 开始抓取数据...")
    
    # NAND Flash
    html = fetch_nand_price()
    if not html:
        send_message("❌ NAND 价格抓取失败")
        return
    
    nand_data = parse_nand_price(html)
    print(f"NAND: 解析 {len(nand_data['items'])} 个规格")
    
    # 股票
    stock_data = get_stock_data()
    print(f"股票: 获取 {len(stock_data)} 只")
    
    # 保存数据
    history = load_history()
    history["records"].insert(0, nand_data)
    history["records"] = history["records"][:30]
    save_nand_data(history)
    
    save_stock_data(stock_data)
    
    # 分析
    changes, alerts, signals, predictions, status = analyze_changes(nand_data, history)
    print(f"变化: {len(changes)} 个, 预警: {len(alerts)} 个, 信号: {len(signals)} 个, 预判: {len(predictions)} 个")
    
    # 生成报告
    report = generate_report(nand_data, changes, alerts, signals, predictions, stock_data, history)
    send_message(report)
    
    print("完成!")

if __name__ == "__main__":
    main()
