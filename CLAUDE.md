# Flyguy 项目架构规范

## 架构模式

本项目采用 **Clean Architecture（整洁架构）** 设计，遵循 **Feature-first（按功能优先）** 的目录组织原则。

### 三层架构划分

1. **Presentation Layer（展示层）**
   - 负责 UI 渲染和用户交互
   - 使用 Riverpod 管理状态
   
2. **Domain Layer（领域层）**
   - 纯业务逻辑，不依赖外部框架
   - 定义实体（Entities）和仓储接口（Repository Interfaces）
   
3. **Data Layer（数据层）**
   - 实现数据获取逻辑（API、数据库）
   - 实现 Domain 层定义的 Repository 接口

## 技术栈

| 技术领域 | 使用方案 |
|---------|---------|
| 状态管理 | `flutter_riverpod` |
| 网络请求 | `dio` + `retrofit` + `retrofit_generator` |
| 数据模型 | `freezed` + `json_serializable` |
| 本地存储 | `hive` + `hive_flutter` |
| 路由导航 | `go_router` |
| 日志工具 | `logger` + `pretty_dio_logger` |

## 目录结构

```
lib/
├── core/                   # 全局通用配置
│   ├── network/            # Dio 实例配置、拦截器
│   ├── theme/              # 主题、颜色、样式
│   └── constants/          # API 地址、常量
├── data/                   # 数据层（实现细节）
│   ├── models/             # 数据模型（DTOs，配合 json_serializable）
│   ├── datasources/        # API 接口实现、本地数据库实现
│   │   ├── remote/         # Retrofit API 接口
│   │   └── local/          # Hive 本地存储
│   └── repositories/       # Repository 的具体实现
├── domain/                 # 领域层（纯业务逻辑）
│   ├── entities/           # 核心实体类（与 UI 剥离）
│   └── repositories/       # Repository 抽象接口
├── presentation/           # UI 层（界面与状态）
│   ├── providers/          # Riverpod Providers/Notifiers
│   ├── widgets/            # 公用组件（Button, Input 等）
│   └── pages/              # 页面级组件
└── main.dart               # 应用入口
```

## 开发规范

### 数据模型规范

- **所有数据模型必须使用 `freezed`**
  ```dart
  @freezed
  class User with _$User {
    const factory User({
      required String id,
      required String name,
    }) = _User;
    
    factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  }
  ```

### Repository 规范

- **必须先在 `domain/repositories/` 定义接口**
  ```dart
  abstract class UserRepository {
    Future<User> getUser(String id);
  }
  ```

- **再在 `data/repositories/` 实现接口**
  ```dart
  class UserRepositoryImpl implements UserRepository {
    @override
    Future<User> getUser(String id) async {
      // 实现逻辑
    }
  }
  ```

### API 接口规范

- **使用 Retrofit 定义 API 接口**
  ```dart
  @RestApi()
  abstract class UserApi {
    factory UserApi(Dio dio) = _UserApi;
    
    @GET('/users/{id}')
    Future<UserModel> getUser(@Path('id') String id);
  }
  ```

- **接口文件统一放在 `data/datasources/remote/`**

### Riverpod Provider 规范

- **Provider 统一放在 `presentation/providers/`**
- **使用代码生成的方式定义 Provider**
  ```dart
  @riverpod
  class UserNotifier extends _$UserNotifier {
    @override
    FutureOr<User?> build() => null;
    
    Future<void> loadUser(String id) async {
      // 逻辑
    }
  }
  ```

### 命名规范

- **文件名**: 使用 `snake_case`（如 `user_repository.dart`）
- **类名**: 使用 `PascalCase`（如 `UserRepository`）
- **变量/函数名**: 使用 `camelCase`（如 `getUserById`）
- **常量**: 使用 `lowerCamelCase`（如 `baseUrl`）或 `SCREAMING_SNAKE_CASE`（如 `API_TIMEOUT`）

## 常用命令

### 代码生成

```bash
# 一次性生成
flutter pub run build_runner build --delete-conflicting-outputs

# 监听模式（推荐开发时使用）
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 依赖管理

```bash
# 安装依赖
flutter pub get

# 清理缓存
flutter clean
```

## AI 辅助工具

### 项目级配置

本项目已配置 `.claude/settings.json`，包含：

- **自动权限许可**: 常用命令（`flutter pub get`, `flutter analyze`, `build_runner` 等）无需手动确认
- **提交前检查 Hook**: 当你说"提交"或"commit"时，自动运行代码格式化和静态分析
- **架构约束规则**: 强制执行 Clean Architecture 分层依赖规则

### 可用 Skills

#### `/gen-feature <feature_name>`

快速生成完整的 Clean Architecture Feature 脚手架

**生成内容：**
- Domain Layer: Entity + Repository Interface
- Data Layer: Model + API + Repository Implementation
- Presentation Layer: Provider + Page

**示例：**
```bash
/gen-feature user
# 自动生成：
# - lib/domain/entities/user_entity.dart
# - lib/domain/repositories/user_repository.dart
# - lib/data/models/user_model.dart
# - lib/data/datasources/remote/user_api.dart
# - lib/data/repositories/user_repository_impl.dart
# - lib/presentation/providers/user_provider.dart
# - lib/presentation/pages/user_page.dart
```

**注意**: 生成后需要运行 `flutter pub run build_runner build --delete-conflicting-outputs`

### 代码质量检查

项目已配置增强的 `analysis_options.yaml`，包含 50+ 严格 Lint 规则：

- ❌ 禁止使用 `print`（使用 `logger` 或 `debugPrint`）
- ✅ 强制尾随逗号（`require_trailing_commas`）
- ✅ 优先使用 `const` 构造函数
- ✅ 强制声明返回类型
- ✅ Flutter 特定规则（`use_build_context_synchronously` 等）

## 环境配置

本项目使用**系统级环境变量**进行配置。

**推荐配置方式：**
- macOS/Linux: 在 `~/.zshrc` 或 `~/.bash_profile` 中配置
- Windows: 在系统环境变量中配置

**需要配置的变量：**
- `API_BASE_URL`: API 基础地址
- `API_TIMEOUT`: 请求超时时间（毫秒）
- `ENV`: 环境标识（development/staging/production）
- `LOG_LEVEL`: 日志级别（debug/info/error）

**示例（macOS/Linux）：**
```bash
export API_BASE_URL="https://api.example.com"
export API_TIMEOUT="30000"
export ENV="development"
export LOG_LEVEL="debug"
```

## 注意事项

1. **依赖方向**: Domain 层不应依赖 Data 和 Presentation 层
2. **代码生成文件**: `.g.dart` 和 `.freezed.dart` 文件不要手动编辑
3. **测试覆盖**: 每个 Feature 都应包含单元测试
4. **错误处理**: 使用 `freezed` 的联合类型处理状态（Loading/Success/Error）
