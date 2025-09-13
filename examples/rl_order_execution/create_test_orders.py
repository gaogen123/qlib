import pandas as pd
import pickle
import os

# 创建简单的测试订单数据
def create_order_data():
    data = {
        'instrument': ['000001.SZ'] * 10,
        'datetime': pd.date_range('2020-01-01 09:30:00', periods=10, freq='1min'),
        'amount': [1000] * 10,
        'order_type': [0] * 10
    }
    
    df = pd.DataFrame(data)
    # 添加date列
    df['date'] = df['datetime'].dt.date
    df = df.set_index(['instrument', 'datetime', 'date'])
    return df

# 确保目录存在
os.makedirs('data/orders/train', exist_ok=True)
os.makedirs('data/orders/valid', exist_ok=True)

# 创建训练数据
train_df = create_order_data()
with open('data/orders/train/000001.SZ.pkl.target', 'wb') as f:
    pickle.dump(train_df, f, protocol=pickle.HIGHEST_PROTOCOL)

# 创建验证数据
valid_df = create_order_data()
with open('data/orders/valid/000001.SZ.pkl.target', 'wb') as f:
    pickle.dump(valid_df, f, protocol=pickle.HIGHEST_PROTOCOL)

print("测试订单数据已创建成功！")
print("目录结构:")
print("data/orders/")
print("├── train/")
print("│   └── 000001.SZ.pkl.target")
print("└── valid/")
print("    └── 000001.SZ.pkl.target")
print("\n数据格式:")
print(train_df.head())

# 测试pickle文件是否可以正确读取
print("\n测试pickle文件读取:")
try:
    test_df = pd.read_pickle('data/orders/train/000001.SZ.pkl.target')
    print("✓ Pickle文件读取成功")
    print(f"数据形状: {test_df.shape}")
except Exception as e:
    print(f"✗ Pickle文件读取失败: {e}")
