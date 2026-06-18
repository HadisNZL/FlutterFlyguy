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

#### 完整工作流示例

```bash
# 1. 创建新模块（提供后端真实 JSON）
/gen-module auth
# 粘贴：{"access_token": "...", "expires_in": 123, ...}

# 2. 运行代码生成
dart run build_runner build --delete-conflicting-outputs

# 3. 根据后端文档调整 API 接口
# 编辑 lib/api/auth_api.dart，修改路径、参数、响应解析

# 4. 测试功能
flutter run

# 5. 后期新增字段
/gen-model auth
# 粘贴新 JSON（包含新字段）

# 6. 重新生成代码
dart run build_runner build --delete-conflicting-outputs
```

---

#### 1. `/gen-module <name>` - 生成完整模块

一键生成 API + Repository + Model + Page + Provider

```bash
/gen-module auth
# AI 会询问：是否提供 JSON 定义？
# 选择 1：直接回车 → 使用通用模板（id + name 字段）
# 选择 2：粘贴 JSON → 根据实际数据结构生成对应字段
```

**示例（推荐方式）**：
```bash
/gen-module auth
# 粘贴后端返回的真实 JSON：
{
  "access_token": "abc123",
  "expires_in": 25920000,
  "token_type": "Bearer",
  "refresh_token": "xyz789"
}
# ✅ 一次生成，字段完全匹配
```

**生成文件**：
- `lib/api/{name}_api.dart` - API 接口层
- `lib/repositories/{name}_repository.dart` - 数据聚合层
- `lib/models/{name}/{name}_model.dart` - Freezed 数据模型
- `lib/pages/{name}/{name}_page.dart` - 页面 UI
- `lib/pages/{name}/providers/{name}_provider.dart` - Riverpod 状态管理

**生成后必做**：
1. **运行代码生成**：
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **手动调整 API 接口**（根据后端文档）：
   ```dart
   // lib/api/auth_api.dart
   Future<AuthModel> login(String username, String password) async {
     final response = await _dio.post(
       '/v1/user/login',  // ← 修改为真实路径
       data: {
         'account': username,  // ← 修改为后端要求的参数名
         'pwd': password,
       },
     );
     // 如果响应有外层包装（如 { "code": 200, "data": {...} }）
     return AuthModel.fromJson(response.data['data']);
     // 如果响应直接是数据，用：
     // return AuthModel.fromJson(response.data);
   }
   ```

**使用场景**：创建新功能模块时使用，节省 80% 样板代码编写时间

---

#### 2. `/gen-model <name>` - 从 JSON 生成/更新模型

自动将 JSON 转换为 Freezed 数据模型，支持**新增字段**

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

**使用场景**：
1. **新建模型** - 快速从 JSON 生成类型安全的数据模型
2. **更新字段** - 后端 API 新增字段时，粘贴新 JSON 即可更新

**示例：后期新增字段**
```bash
# 假设 auth_model.dart 已存在，后端新增了 user_id 字段
/gen-model auth
# 粘贴包含新字段的完整 JSON：
{
  "access_token": "...",
  "expires_in": 123,
  "user_id": "user_001"  // ← 新增字段
}
# ✅ 自动更新模型，添加 userId 字段
```

**注意**：
- JSON 中的 `snake_case` 字段会自动添加 `@JsonKey` 映射为 `camelCase`
- 更新后需运行 `dart run build_runner build --delete-conflicting-outputs`

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
