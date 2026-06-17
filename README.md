# Flyguy 项目

基于 **实用型 MVVM (Plan B)** 架构的 Flutter 项目

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行项目
flutter run

# 代码生成（开发时推荐）
dart run build_runner watch --delete-conflicting-outputs
```

## 架构说明

本项目采用 **实用型 MVVM** 架构，详细规范请查看 [CLAUDE.md](CLAUDE.md)

### 核心理念
- ✅ 极简实用，拒绝过度设计
- ✅ 按业务模块组织代码
- ✅ 使用 Riverpod AsyncValue 统一处理异步状态
- ❌ 不使用抽象接口和 Dartz

### 目录结构

```
lib/
├── core/              # 全局配置
│   ├── dio/           # Dio 实例与拦截器
│   │   ├── dio_client.dart
│   │   └── interceptors/
│   ├── storage/       # 本地缓存工具
│   ├── constants/     # 全局常量
│   ├── extensions/    # 扩展方法
│   └── utils/         # 工具函数
├── api/               # API 接口层（Dio 直接实现）
├── repositories/      # 数据聚合层（只有实现类）
├── models/            # Freezed 数据模型（按模块分包）
├── pages/             # 页面（按模块分包）
├── widgets/           # 通用组件
└── main.dart          # 应用入口
```

## 开发工具

### AI 辅助 Skills

- `/gen-feature <name>` - 快速生成 Feature 脚手架

### 常用命令

```bash
# 代码生成
dart run build_runner build --delete-conflicting-outputs

# 代码格式化
dart format .

# 静态分析
flutter analyze

# 运行测试
flutter test

# 清理项目
flutter clean
```

## 技术栈

| 技术领域 | 使用方案 |
|---------|---------|
| 状态管理 | `flutter_riverpod` + `@riverpod` |
| 网络请求 | `dio` |
| 数据模型 | `freezed` + `json_serializable` |
| 本地存储 | `hive` + `hive_flutter` |
| 路由导航 | `go_router` |
| 日志工具 | `logger` + `pretty_dio_logger` |

## 开发规范

1. 所有数据模型使用 `freezed` + `json_serializable`
2. Repository 直接写实现类，不要抽象接口
3. 使用 `AsyncValue` 处理异步状态，不使用 `Either`
4. 提交前运行 `flutter analyze`
5. 遵循 YAGNI 原则，不做过度设计
