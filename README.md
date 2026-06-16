# Flyguy 项目

Flutter Clean Architecture 示例项目

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行项目
flutter run

# 代码生成（开发时推荐）
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 架构说明

本项目采用 **Clean Architecture（整洁架构）** 设计，详细规范请查看 [CLAUDE.md](CLAUDE.md)

### 目录结构

```
lib/
├── core/          # 全局配置（网络、主题、常量）
├── data/          # 数据层（API、模型、Repository 实现）
├── domain/        # 领域层（实体、Repository 接口）
└── presentation/  # 展示层（Provider、页面、组件）
```

## 开发工具

### AI 辅助 Skills

- `/gen-feature <name>` - 快速生成 Feature 脚手架

### 常用命令

```bash
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

- 状态管理: `flutter_riverpod`
- 网络请求: `dio` + `retrofit`
- 数据模型: `freezed` + `json_serializable`
- 本地存储: `hive`
- 路由导航: `go_router`

## 贡献指南

1. 所有数据模型使用 `freezed`
2. Repository 先定义接口再实现
3. 提交前运行 `flutter analyze`
4. 遵循 Feature-first 组织原则
