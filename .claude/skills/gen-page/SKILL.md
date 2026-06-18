---
description: 生成页面 + Provider（可选）。支持纯 UI 页面、单接口页面、多接口组合页面。
---

# gen-page

生成 UI 层（Page + Provider），不生成数据层。

## 使用方式

```bash
/gen-page profile
# AI 会询问：需要状态管理吗？
# 选择 1：no → 生成纯 UI 页面（StatelessWidget）
# 选择 2：yes → 生成带 Provider 的页面（ConsumerWidget）
```

## 生成文件

### 纯 UI 页面（无状态管理）
```
lib/pages/{name}/
└── {name}_page.dart
```

### 带状态管理的页面
```
lib/pages/{name}/
├── {name}_page.dart
└── providers/{name}_provider.dart
```

## 使用场景

### 场景 1：纯 UI 页面
```bash
/gen-page about
# 回答：不需要状态管理
# 适用于：关于页面、静态内容展示
```

### 场景 2：单接口页面
```bash
# 1. 先生成数据层
/gen-api user

# 2. 生成页面
/gen-page user-detail
# 回答：需要状态管理
# 生成 Provider 模板，包含详细注释指导如何加载数据
```

### 场景 3：多接口组合页面
```bash
# 1. 先生成多个数据层
/gen-api user
/gen-api order
/gen-api address

# 2. 生成页面
/gen-page profile
# 回答：需要状态管理
# Provider 模板包含多种数据加载方式的注释示例
```

## Provider 模板说明

生成的 Provider 包含以下注释示例：

- **场景 1**：单一数据源（调用一个接口）
- **场景 2**：多个数据源并发加载（Future.wait）
- **场景 3**：多个数据源串行加载（有依赖关系）
- **场景 4**：带参数的页面（如商品详情传入 productId）
- **聚合状态类**：如何手动创建聚合多个数据的状态类

## 生成后操作

1. **运行代码生成**（如果创建了 Provider）：
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **根据注释填充业务逻辑**：
   - 选择合适的数据加载方式
   - 实现具体的 UI 布局
   - 添加交互逻辑

## 与 /gen-module 的区别

| Skill | 生成内容 | 适用场景 |
|-------|---------|---------|
| `/gen-page` | Page + Provider（可选） | 纯 UI / 复杂页面组合多个接口 |
| `/gen-module` | API + Repository + Model + Page + Provider | 简单模块，1:1:1 关系 |
