#!/usr/bin/env python3
"""
Qlib 基础工作流示例

这个示例展示了使用 Qlib 进行量化投资的基本流程：
1. 初始化 Qlib
2. 数据加载和预处理
3. 模型训练
4. 预测和回测
5. 结果分析
"""

import qlib
from qlib.constant import REG_CN
from qlib.utils import init_instance_by_config
from qlib.workflow import R
from qlib.workflow.record_temp import SignalRecord, PortAnaRecord
from qlib.contrib.evaluate import backtest_daily
from qlib.contrib.strategy import TopkDropoutStrategy
import pandas as pd
import numpy as np

def init_qlib():
    """初始化 Qlib"""
    print("正在初始化 Qlib...")
    
    # 使用默认配置初始化
    qlib.init(provider_uri='~/.qlib/qlib_data/cn_data', region=REG_CN)
    print("Qlib 初始化完成")

def load_data():
    """加载数据"""
    print("正在加载数据...")
    
    # 定义数据加载器
    data_handler_config = {
        "start_time": "2020-01-01",
        "end_time": "2023-12-31",
        "fit_start_time": "2020-01-01",
        "fit_end_time": "2022-12-31",
        "instruments": "csi300",
        "infer_processors": [
            {"class": "RobustZScoreNorm", "kwargs": {"fields_group": "feature", "clip_outlier": True}},
            {"class": "Fillna", "kwargs": {"fields_group": "feature"}},
        ],
        "learn_processors": [
            {"class": "DropnaLabel"},
            {"class": "CSRankNorm", "kwargs": {"fields_group": "label"}},
        ],
    }
    
    data_handler = init_instance_by_config(data_handler_config)
    print("数据加载完成")
    
    return data_handler

def train_model(data_handler):
    """训练模型"""
    print("正在训练模型...")
    
    # 定义模型配置
    model_config = {
        "class": "LGBModel",
        "module_path": "qlib.contrib.model.gbdt",
        "kwargs": {
            "loss": "mse",
            "colsample_bytree": 0.8879,
            "learning_rate": 0.2,
            "subsample": 0.8789,
            "lambda_l1": 205.6999,
            "lambda_l2": 580.9768,
            "max_depth": 8,
            "num_leaves": 210,
            "num_threads": 20,
        }
    }
    
    model = init_instance_by_config(model_config)
    
    # 训练模型
    with R.start(experiment_name="basic_workflow"):
        model.fit(dataset=data_handler)
        R.log_metrics(train=model.get_score())
    
    print("模型训练完成")
    return model

def backtest_strategy(model, data_handler):
    """回测策略"""
    print("正在进行回测...")
    
    # 定义策略
    strategy_config = {
        "class": "TopkDropoutStrategy",
        "module_path": "qlib.contrib.strategy.signal_strategy",
        "kwargs": {
            "model": model,
            "dataset": data_handler,
            "topk": 50,
            "n_drop": 5,
        },
    }
    
    strategy = init_instance_by_config(strategy_config)
    
    # 执行回测
    portfolio_config = {
        "account": 100000000,
        "benchmark": "SH000300",
        "exchange_kwargs": {
            "freq": "day",
            "limit_threshold": 0.095,
            "deal_price": "close",
            "open_cost": 0.0005,
            "close_cost": 0.0015,
            "min_cost": 5,
        },
    }
    
    # 回测分析
    with R.start(experiment_name="basic_workflow_backtest"):
        analysis = dict(
            class="RiskAnalysis",
            module_path="qlib.contrib.evaluate",
            kwargs=dict(
                strategy=strategy,
                benchmark="SH000300",
                account=portfolio_config["account"],
                benchmark_kwargs=dict(freq="day"),
            ),
        )
        
        analysis_d = init_instance_by_config(analysis)
        analysis_d.generate()
        
        # 记录结果
        R.log_objects(**analysis_d.get())
    
    print("回测完成")
    return analysis_d

def analyze_results(analysis_d):
    """分析结果"""
    print("正在分析结果...")
    
    # 获取分析结果
    report_normal, positions_normal = analysis_d.get()
    
    print("\n=== 回测结果分析 ===")
    print(f"年化收益率: {report_normal.get('risk_analysis', {}).get('annualized_return', 'N/A')}")
    print(f"最大回撤: {report_normal.get('risk_analysis', {}).get('max_drawdown', 'N/A')}")
    print(f"夏普比率: {report_normal.get('risk_analysis', {}).get('sharpe', 'N/A')}")
    print(f"信息比率: {report_normal.get('risk_analysis', {}).get('information_ratio', 'N/A')}")
    
    return report_normal, positions_normal

def main():
    """主函数"""
    print("开始 Qlib 基础工作流示例")
    print("=" * 50)
    
    try:
        # 1. 初始化 Qlib
        init_qlib()
        
        # 2. 加载数据
        data_handler = load_data()
        
        # 3. 训练模型
        model = train_model(data_handler)
        
        # 4. 回测策略
        analysis_d = backtest_strategy(model, data_handler)
        
        # 5. 分析结果
        report, positions = analyze_results(analysis_d)
        
        print("\n工作流执行完成！")
        
    except Exception as e:
        print(f"执行过程中出现错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
