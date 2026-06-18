---
description: 生成 API + Repository + Model 数据层。适用于只需要接口层，不需要 UI 的场景。
---

# gen-api

生成数据层（API + Repository + Model），不生成 UI 层。

## 使用方式

```bash
/gen-api user
# AI 会询问：是否提供 JSON 定义？
# 选择 1：直接回车 → 使用通用模板（id + name 字段）
# 选择 2：粘贴 JSON → 根据实际数据结构生成对应字段
```

## 生成文件

```
lib/
├── api/{name}_api.dart                    # Dio API 接口
├── repositories/{name}_repository.dart    # 数据聚合层
└── models/{name}/{name}_model.dart        # Freezed 模型
```

## 使用场景

1. **只需要接口，不需要独立页面** - 如全局配置接口、工具类接口
2. **复杂页面，需要组合多个接口** - 先用 `/gen-api` 生成多个数据层，再用 `/gen-page` 生成页面
3. **API 优先开发** - 先定义数据层，UI 层后续再加

## 生成后操作

1. **运行代码生成**：
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **根据后端文档调整 API 方法**（路径、参数、响应解析）

## 与 /gen-module 的区别

| Skill | 生成内容 | 适用场景 |
|-------|---------|---------|
| `/gen-api` | API + Repository + Model | 只要数据层 / 复杂页面组合多个接口 |
| `/gen-module` | API + Repository + Model + Page + Provider | 简单模块，1:1:1 关系 |
