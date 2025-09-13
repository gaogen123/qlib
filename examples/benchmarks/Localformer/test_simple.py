#!/usr/bin/env python3
"""
简单的 Localformer 测试脚本
"""

import sys
from pathlib import Path

# 添加 qlib 路径
sys.path.append(str(Path(__file__).parent.parent.parent.parent))

def test_localformer():
    """测试 Localformer 模型"""
    try:
        print("🔍 测试导入 Localformer 模型...")
        
        # 尝试导入模型
        from qlib.contrib.model.pytorch_localformer_ts import LocalformerModel
        print("✅ LocalformerModel 导入成功")
        
        # 尝试创建模型实例
        model = LocalformerModel(
            d_feat=20,
            d_model=64,
            batch_size=1024,
            n_epochs=1,
            lr=0.001
        )
        print("✅ LocalformerModel 实例创建成功")
        
        # 检查模型属性
        print("📊 模型属性列表:")
        for attr in dir(model):
            if not attr.startswith('_'):
                print(f"  - {attr}")
        
        # 检查模型参数
        if hasattr(model, 'd_feat'):
            print(f"📊 d_feat: {model.d_feat}")
        if hasattr(model, 'd_model'):
            print(f"📊 d_model: {model.d_model}")
        if hasattr(model, 'batch_size'):
            print(f"📊 batch_size: {model.batch_size}")
        if hasattr(model, 'n_epochs'):
            print(f"📊 n_epochs: {model.n_epochs}")
        if hasattr(model, 'lr'):
            print(f"📊 lr: {model.lr}")
        
        # 检查设备
        if hasattr(model, 'device'):
            print(f"📊 设备: {model.device}")
        
        return True
        
    except Exception as e:
        print(f"❌ 测试失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_localformer()
    if success:
        print("🎉 所有测试通过！")
    else:
        print("💥 测试失败")
        sys.exit(1)
