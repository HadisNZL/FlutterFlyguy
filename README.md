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

本项目配置了 5 个 AI 代码生成工具，可大幅提升开发效率：

#### 核心设计理念

**灵活组合，按需生成**

- 简单场景：用 `/gen-module` 一键生成完整模块
- 复杂场景：用 `/gen-api` + `/gen-page` 灵活组合
- 更新字段：用 `/gen-model` 快速更新

---

#### 工作流示例

##### 场景 1：简单 CRUD 模块（1 Page = 1 API）

```bash
# 一键生成完整模块
/gen-module user
# 粘贴 JSON → 生成 API + Repository + Model + Page + Provider

# 运行代码生成
dart run build_runner build --delete-conflicting-outputs

# 根据后端文档调整 API 接口
# 编辑 lib/api/user_api.dart
```

##### 场景 2：复杂页面（1 Page = 多个 API）

```bash
# 1. 分别生成多个数据层
/gen-api user
/gen-api order
/gen-api address

# 2. 运行代码生成
dart run build_runner build --delete-conflicting-outputs

# 3. 生成组合页面
/gen-page profile
# 选择：需要状态管理
# 生成的 Provider 包含详细注释，指导如何组合多个 Repository

# 4. 根据注释填充业务逻辑
# 编辑 lib/pages/profile/providers/profile_provider.dart
```

##### 场景 3：纯 UI 页面（无接口）

```bash
/gen-page about
# 选择：不需要状态管理
# 生成纯 StatelessWidget 页面
```

##### 场景 4：后期新增字段

```bash
/gen-model user
# 粘贴包含新字段的完整 JSON
# 只更新 Model，不影响其他文件

dart run build_runner build --delete-conflicting-outputs
```

---

#### Skills 详解

##### 1. `/gen-module <name>` - 生成完整模块

**适用场景**：简单 CRUD，1 Page = 1 API

一键生成 API + Repository + Model + Page + Provider

```bash
/gen-module auth
# AI 询问：是否提供 JSON 定义？
# 粘贴后端真实 JSON（推荐）
{
  "access_token": "abc123",
  "expires_in": 25920000,
  "token_type": "Bearer",
  "refresh_token": "xyz789"
}
```

**生成文件**：
- `lib/api/{name}_api.dart` - API 接口层
- `lib/repositories/{name}_repository.dart` - 数据聚合层
- `lib/models/{name}/{name}_model.dart` - Freezed 数据模型
- `lib/pages/{name}/{name}_page.dart` - 页面 UI
- `lib/pages/{name}/providers/{name}_provider.dart` - Riverpod 状态管理

**生成后必做**：
1. 运行 `dart run build_runner build --delete-conflicting-outputs`
2. 根据后端文档调整 API 方法（路径、参数、响应解析）

---

##### 2. `/gen-api <name>` - 生成数据层

**适用场景**：只要接口，不要页面 / 复杂页面组合多个接口

只生成 API + Repository + Model

```bash
/gen-api product
# AI 询问：是否提供 JSON 定义？
# 粘贴 JSON 或回车使用通用模板
```

**生成文件**：
- `lib/api/{name}_api.dart`
- `lib/repositories/{name}_repository.dart`
- `lib/models/{name}/{name}_model.dart`

**使用场景**：
- 全局配置接口、工具类接口
- 复杂页面需要组合多个接口（先用 `/gen-api` 生成多个数据层，再用 `/gen-page` 生成页面）

---

##### 3. `/gen-page <name>` - 生成页面层

**适用场景**：纯 UI 页面 / 复杂页面组合多个接口

只生成 Page + Provider（可选）

```bash
/gen-page profile
# AI 询问：需要状态管理吗？
# yes → 生成 ConsumerWidget + Provider（带详细注释）
# no  → 生成 StatelessWidget（纯 UI）
```

**生成文件**：
- 需要状态管理：`lib/pages/{name}/{name}_page.dart` + `lib/pages/{name}/providers/{name}_provider.dart`
- 纯 UI 页面：`lib/pages/{name}/{name}_page.dart`

**Provider 模板注释包含**：
- 场景 1：单一数据源（调用一个接口）
- 场景 2：多个数据源并发加载（Future.wait）
- 场景 3：多个数据源串行加载（有依赖关系）
- 场景 4：带参数的页面（如 productId）
- 聚合状态类：如何手动创建聚合多个数据的状态类

---

##### 4. `/gen-model <name>` - 从 JSON 生成/更新模型

**适用场景**：新建模型 / 后期新增字段

只生成 Model 文件

```bash
/gen-model user
# AI 询问：是否提供 JSON 定义？
# 粘贴 JSON
{
  "id": "123",
  "name": "John",
  "email": "john@example.com"
}
```

**生成文件**：`lib/models/{name}/{name}_model.dart`

**使用场景**：
1. 新建模型 - 快速从 JSON 生成类型安全的数据模型
2. 更新字段 - 后端 API 新增字段时，粘贴新 JSON 即可更新

**注意**：
- JSON 中的 `snake_case` 字段会自动添加 `@JsonKey` 映射为 `camelCase`
- 更新后需运行 `dart run build_runner build --delete-conflicting-outputs`

---

##### 5. `/add-interceptor <type>` - 添加拦截器

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

#### Skills 对比总结

| Skill | 生成内容 | 适用场景 | 包含 Page |
|-------|---------|---------|----------|
| `/gen-module` | API + Repo + Model + Page + Provider | 简单 CRUD，1:1:1 关系 | ✅ |
| `/gen-api` | API + Repo + Model | 只要数据层 / 多接口组合 | ❌ |
| `/gen-page` | Page + Provider（可选） | 纯 UI / 组合多个接口 | ✅ |
| `/gen-model` | Model | 新建/更新字段 | ❌ |
| `/add-interceptor` | Dio 拦截器 | 网络中间件 | ❌ |

**选择建议**：
- 🎯 **简单场景**：用 `/gen-module` 一键生成
- 🎯 **复杂页面**：用 `/gen-api` 分别生成数据层，再用 `/gen-page` 组合
- 🎯 **纯 UI 页面**：直接用 `/gen-page`，选择不需要状态管理
- 🎯 **更新字段**：用 `/gen-model`

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

## 全局共享状态

### 何时需要全局 Provider？

当数据需要**跨多个页面共享**，且**一处修改、多处自动刷新**时，创建全局 Provider。

**典型场景**：
- 用户信息（修改头像后，首页、个人中心、侧边栏同时更新）
- 购物车数量（加入购物车后，商品详情页、首页角标同时更新）
- 未读消息数
- 应用配置（主题、语言）

### 使用方式

```dart
// 1. 创建全局 Provider（lib/providers/global/）
@riverpod
class GlobalUser extends _$GlobalUser {
  @override
  Future<UserModel?> build() async {
    return await ref.read(userRepositoryProvider).getCurrentUser();
  }

  Future<void> updateAvatar(String newAvatar) async {
    await ref.read(userRepositoryProvider).updateAvatar(newAvatar);
    ref.invalidateSelf(); // 刷新自己
  }
}

// 2. 多个页面 watch 全局 Provider
// 页面 A：个人中心
final user = ref.watch(globalUserProvider);

// 页面 B：首页顶部
final user = ref.watch(globalUserProvider);

// 3. 修改数据（任何页面）
await ref.read(globalUserProvider.notifier).updateAvatar(newAvatar);
// ✅ 所有 watch 的页面自动刷新
```

**详细说明**：查看 [CLAUDE.md - 3.1.1 全局共享状态 Provider](CLAUDE.md#311-全局共享状态-provider)

