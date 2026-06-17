# Flyguy 项目

基于 **实用型 MVVM** 架构的 Flutter 项目

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

### AI 辅助 Skills（需要 Claude Code）

本项目配置了 3 个 AI 代码生成工具，可大幅提升开发效率：

#### 1. `/gen-module <name>` - 生成完整模块

一键生成 API + Repository + Model + Page + Provider

```bash
/gen-module auth      # 生成认证模块
/gen-module user      # 生成用户模块
/gen-module product   # 生成商品模块
```

**生成文件**：
- `lib/api/{name}_api.dart`
- `lib/repositories/{name}_repository.dart`
- `lib/models/{name}/{name}_model.dart`
- `lib/pages/{name}/{name}_page.dart`
- `lib/pages/{name}/providers/{name}_provider.dart`

**使用场景**：创建新功能模块时使用，节省 80% 样板代码编写时间

---

#### 2. `/gen-model <name>` - 从 JSON 生成模型

自动将 JSON 转换为 Freezed 数据模型

```bash
/gen-model user

# 然后粘贴 JSON：
{
  "id": "123",
  "name": "John",
  "email": "john@example.com"
}
```

**生成文件**：`lib/models/{name}/{name}_model.dart`

**使用场景**：对接后端 API 时，快速生成类型安全的数据模型

---

#### 3. `/add-interceptor <type>` - 添加拦截器

快速添加常用的 Dio 拦截器

```bash
/add-interceptor token    # JWT Token 自动注入
/add-interceptor refresh  # Token 过期自动刷新
/add-interceptor retry    # 网络失败自动重试
/add-interceptor error    # 统一错误处理
```

**生成位置**：`lib/core/dio/interceptors/`

**使用场景**：配置网络层中间件

---

**注意**：使用 Skills 需要安装 [Claude Code CLI](https://docs.anthropic.com/claude/docs/claude-code) 或使用 VS Code 的 Claude 插件。

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
