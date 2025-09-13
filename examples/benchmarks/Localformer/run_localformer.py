#!/usr/bin/env python3
"""
简化版 Localformer 运行脚本
避免 MLflow 相关的问题
"""

import os
import sys
import yaml
import argparse
from pathlib import Path

# 添加 qlib 路径
sys.path.append(str(Path(__file__).parent.parent.parent.parent))

def run_localformer(config_path, dataset_type="Alpha158"):
    """
    运行 Localformer 模型
    
    Args:
        config_path: 配置文件路径
        dataset_type: 数据集类型 (Alpha158 或 Alpha360)
    """
    try:
        # 初始化 qlib（使用简单的本地配置）
        import qlib
        
        # 设置基本配置，不使用实验管理器
        qlib.init(
            provider_uri="~/.qlib/qlib_data/cn_data",
            region="cn"
        )
        
        print(f"✅ Qlib 初始化成功")
        print(f"📁 使用配置文件: {config_path}")
        print(f"📊 数据集类型: {dataset_type}")
        
        # 运行模型训练
        from qlib.workflow import R
        from qlib.utils import init_instance_by_config
        
        # 加载配置
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        
        print("🚀 开始运行 Localformer 模型...")
        
        # 从配置创建模型和数据集
        model = init_instance_by_config(config["task"]["model"])
        dataset = init_instance_by_config(config["task"]["dataset"])
        
        print(f"📊 模型类型: {type(model).__name__}")
        print(f"📊 数据集类型: {type(dataset).__name__}")
        
        # 使用配置文件运行工作流
        with R.start(experiment_name=f"Localformer_{dataset_type}"):
            # 训练模型
            print("🔧 开始训练模型...")
            model.fit(dataset)
            print("✅ 模型训练完成")
            
            # 生成预测
            recorder = R.get_recorder()
            print("🔮 开始生成预测...")
            
            # 保存模型
            R.save_objects(**{"localformer_model.pkl": model})
            print("💾 模型已保存")
            
            print("✅ 模型训练和评估完成")
            
    except Exception as e:
        print(f"❌ 运行失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return False
    
    return True

def main():
    parser = argparse.ArgumentParser(description="运行 Localformer 模型")
    parser.add_argument("--config", type=str, default="workflow_config_localformer_Alpha158.yaml",
                       help="配置文件路径")
    parser.add_argument("--dataset", type=str, choices=["Alpha158", "Alpha360"], default="Alpha158",
                       help="数据集类型")
    
    args = parser.parse_args()
    
    # 检查配置文件是否存在
    config_path = Path(args.config)
    if not config_path.exists():
        print(f"❌ 配置文件不存在: {config_path}")
        return 1
    
    # 运行模型
    success = run_localformer(str(config_path), args.dataset)
    
    if success:
        print("🎉 Localformer 运行成功完成！")
        return 0
    else:
        print("💥 Localformer 运行失败")
        return 1

if __name__ == "__main__":
    sys.exit(main())
