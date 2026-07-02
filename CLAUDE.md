# CLAUDE.md - 项目架构与 AI 编程规范指南

本项目采用 **实用型 MVVM** 架构设计，核心目标是在"开发效率"与"商业级项目的可维护性"之间取得完美平衡。
作为 AI 编程助手，在为本项目生成、重构或修改代码时，你必须**严格理解并遵守**以下所有架构约定。

## 1. 核心数据流转规范

```text
本地缓存(Sp/Isar) ↘
                   Repository（数据聚合层）
远程接口   → Api层 ↗
                   ↓
               Freezed Model
                   ↓
          Riverpod Provider（ViewModel）
                   ↓
             Page / Widget（View）
```

## 2. 目录结构约束 (`lib/` 根目录下)

严禁随意发明或创建新的根级目录，所有代码必须归入以下明确定义的层级中：

```
lib/
├── core/                   # 全局基础支撑能力
│   ├── dio/                # Dio 全局实例、拦截器
│   │   ├── dio_client.dart # 全局 Dio 实例配置
│   │   └── interceptors/   # 自定义拦截器（Token、日志、错误）
│   ├── storage/            # 本地缓存工具封装（SharedPreferences / Isar）
│   ├── constants/          # 全局常量（颜色、尺寸、接口地址、错误码枚举）
│   ├── exceptions/         # 业务异常类（GlobalHandledException 子类）
│   ├── handlers/           # 全局错误处理器（策略模式实现）
│   ├── extensions/         # 通用扩展方法（String, DateTime 等）
│   └── utils/              # 无状态的纯工具函数（如格式化、Toast、Dialog等）
├── api/                    # 纯网络请求接口层（Dio 直接实现）
├── repositories/           # 数据聚合层（只有实现类，无抽象接口）
├── models/                 # 唯一的数据实体层（按模块分包）
│   ├── user/               # 业务模型（如 user_model.dart）
│   └── states/             # 聚合状态类（如 profile_state.dart，用于组合多个 Model）
├── providers/              # Provider 层
│   └── global/             # 全局共享状态 Provider（用户信息、购物车、全局错误等）
├── pages/                  # 视图页面层（按业务模块分包）
│   └── {module}/
│       ├── {module}_page.dart
│       └── providers/      # 页面级 Provider
├── widgets/                # 全局高频复用的基础小组件
└── main.dart               # 应用入口
```

## 2.1 常量管理规范

### 核心原则
**所有硬编码的字符串常量必须集中管理在 `lib/core/constants/app_constants.dart`**

### 必须统一管理的常量类型

#### 路由相关
- 路由路径（如 `/main`, `/login`）
- 路由参数 key（如 `fromLogin`, `userId`）

#### 存储相关
- Hive Box 名称（如 `auth_token`, `login_init`）
- 存储 Key 名称（如 `token`, `account_`）
- 存储 Key 前缀（需要动态拼接的，如 `account_${id}`）

#### 配置相关
- API 基础 URL
- 超时时间
- 其他全局配置项

#### 错误码相关
- 特殊业务错误码（如 `BusinessErrorCode.accountConflict = 74015`）

### AppConstants 类结构

```dart
/// 应用全局常量
/// 集中管理所有硬编码的字符串常量，便于维护和修改
class AppConstants {
  AppConstants._(); // 私有构造函数，防止实例化

  /// ==================== 路由路径 ====================
  static const String routeMain = '/main';
  static const String routeLogin = '/login';

  /// ==================== 路由参数 ====================
  static const String extraFromLogin = 'fromLogin';

  /// ==================== 存储 Box 名称 ====================
  static const String boxAuthToken = 'auth_token';
  static const String boxLoginInit = 'login_init';

  /// ==================== 存储 Key ====================
  static const String keyToken = 'token';
  static const String keyLoginInitPrefix = 'account_';

  /// 生成 LoginInit 存储的完整 key
  static String loginInitKey(int accountId) => '${keyLoginInitPrefix}$accountId';
}
```

### 使用规范

#### ✅ 正确示例
```dart
// 路由跳转
context.go(AppConstants.routeMain, extra: {AppConstants.extraFromLogin: true});

// 存储操作
final box = Hive.box<TokenModel>(AppConstants.boxAuthToken);
await box.put(AppConstants.keyToken, token);

// 动态 key
final data = box.get(AppConstants.loginInitKey(accountId));
```

#### ❌ 错误示例
```dart
// 硬编码路由路径
context.go('/main', extra: {'fromLogin': true});  // ❌

// 硬编码 Box 名称
final box = Hive.box<TokenModel>('auth_token');  // ❌

// 硬编码 Key
await box.put('token', token);  // ❌

// 硬编码拼接
final data = box.get('account_$accountId');  // ❌
```

### 新增常量的流程

1. **在 `app_constants.dart` 中定义常量**
   - 选择合适的分类（路由/存储/配置等）
   - 添加清晰的注释说明用途

2. **替换所有使用该常量的地方**
   - 使用 IDE 全局搜索硬编码字符串
   - 逐个替换为 `AppConstants.xxx`

3. **验证编译通过**
   - 确保没有遗漏的硬编码

### 好处

✅ **集中管理**：所有常量在一个文件中，便于查找和修改  
✅ **类型安全**：通过静态常量避免拼写错误  
✅ **易于维护**：修改常量只需改一个地方  
✅ **可扩展**：未来添加新常量很容易

## 3. 各层级严格编程纪律

### 3.1 视图模型层 (Riverpod Providers)
- **角色**：界面的 ViewModel，负责承载界面的 `loading/error/data` 状态
- **规范**：
  - 严禁引入 `dartz` 或自定义 `Either`。必须**原生且唯一**地使用 Riverpod 的 `AsyncValue` 来处理异步网络状态
  - 优先使用 `@riverpod` 代码生成器语法来定义 Provider
  - Provider 文件统一放在对应页面的同级 `providers/` 目录
  - Provider 只负责"调用 Repository -> 抛出 State 给 UI"，不要在 Provider 内写繁琐的 JSON 字段拼接
- **数据加载模式**：
  - **单一数据源**：直接调用一个 Repository 方法
  - **并发加载**：多个接口无依赖关系，使用 `Future.wait()` 并行请求
  - **串行加载**：后续接口依赖前面接口的返回值，按顺序调用
  - **聚合状态**：如需组合多个 Model，手动创建聚合状态类（Freezed），而非在 Provider 中拼接临时 Map

### 3.1.1 全局共享状态 Provider

**何时需要全局 Provider？**

当满足以下条件时，应创建全局共享状态 Provider：
- ✅ 数据需要**跨多个页面**共享（如用户信息、购物车数量）
- ✅ 一处修改，**多处自动刷新**（如修改头像后，首页、个人中心、侧边栏同时更新）
- ✅ 数据具有**全局生命周期**（应用启动到退出期间持续存在）

**典型的全局状态**：
- 用户信息（头像、昵称、等级、登录态）
- 购物车数量
- 未读消息数
- 应用配置（主题、语言）

**目录结构**：
```
lib/
└── providers/
    └── global/                      # 全局 Provider 统一目录
        ├── global_user_provider.dart
        ├── global_cart_provider.dart
        └── global_config_provider.dart
```

**代码示例**：
```dart
// lib/providers/global/global_user_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user/user_model.dart';
import '../../repositories/user_repository.dart';

part 'global_user_provider.g.dart';

@riverpod
class GlobalUser extends _$GlobalUser {
  @override
  Future<UserModel?> build() async {
    // 从本地缓存或远程接口加载
    final cachedUser = await ref.read(storageProvider).getUser();
    if (cachedUser != null) return cachedUser;
    
    try {
      final user = await ref.read(userRepositoryProvider).getCurrentUser();
      await ref.read(storageProvider).saveUser(user);
      return user;
    } catch (e) {
      return null; // 未登录
    }
  }

  // 业务方法：修改头像
  Future<void> updateAvatar(String newAvatar) async {
    await ref.read(userRepositoryProvider).updateAvatar(newAvatar);
    ref.invalidateSelf(); // 刷新自己，触发所有 watch 的页面更新
  }

  // 业务方法：登出
  Future<void> logout() async {
    await ref.read(storageProvider).clearUser();
    state = const AsyncValue.data(null);
  }
}
```

**使用方式**：
```dart
// 页面 A：个人中心
class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(globalUserProvider);
    
    return userAsync.when(
      data: (user) => Text(user?.name ?? '未登录'),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('加载失败'),
    );
  }
}

// 页面 B：首页顶部
class HomeHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider).value;
    return CircleAvatar(backgroundImage: NetworkImage(user?.avatar ?? ''));
  }
}

// 修改头像（任何页面）
await ref.read(globalUserProvider.notifier).updateAvatar(newAvatar);
// ✅ 所有 watch globalUserProvider 的页面自动刷新
```

**核心原则**：
- ❌ 不要为每个页面都创建全局 Provider
- ❌ 不要把页面级的状态提升为全局状态
- ✅ 只为真正需要跨页面共享的数据创建全局 Provider
- ✅ 全局 Provider 数量应控制在 3-5 个以内

### 3.2 数据聚合层 (Repositories)
- **角色**：核心业务逻辑承载者，对接 `api` 和 `storage`
- **铁律：绝对不要写 `abstract class` 抽象接口**。保持实用主义，直接写实现类
- **依赖注入**：所有 Repository 必须通过 Riverpod Provider 注入，便于测试和依赖管理
  - 示例：`final authRepoProvider = Provider((ref) => AuthRepository(ref.watch(authApiProvider)));`
- **职责**：
  - 多接口并发请求与数据聚合
  - 数据脱敏、默认值兜底、格式化转换
  - 持久化处理（如：获取远端数据后同步写入本地数据库）
- **粒度**：按**业务领域（Domain）**划分，而不是按接口划分。例如 `AuthRepository`（负责登录/注册/登出），而不是按单个接口拆分
- **聚合状态类**：当 Provider 需要组合多个 Repository 的数据时，在 `models/states/` 目录下创建聚合状态类（Freezed），而非在 Provider 中返回 Map 或动态类型

### 3.3 数据模型层 (Models)
- **铁律：一套 Freezed 走天下**。严禁将模型强行拆分为 DTO 和 Entity 两层
- **规范**：
  - 所有数据类必须使用 `Freezed` 搭配 `json_serializable` 生成
  - 保证对象的不可变性（Immutable）
  - 简单的派生数据（如组合姓和名），直接在 Freezed 类中写 getter 扩展即可

### 3.4 视图层 (Pages / Widgets)
- **角色**：纯粹的 UI 渲染器
- **规范**：
  - **严禁**在 UI 代码（如 `onPressed` 回调中）直接发起 Dio 网络请求
  - UI 只做两件事：触发 Provider 的方法（如 `ref.read(loginProvider.notifier).login()`），以及根据 `AsyncValue` 绘制界面

### 3.5 应用初始化
- **规范**：
  - 在 `main()` 中集中初始化全局依赖（Dio、Storage、日志等）
  - 使用 `ProviderScope` 管理全局状态
  - 异步初始化任务使用 `Future.wait()` 并行执行，避免阻塞主线程

## 4. 技术栈

| 技术领域 | 使用方案 |
|---------|---------|
| 状态管理 | `flutter_riverpod` + `@riverpod` 代码生成 |
| 网络请求 | `dio` + 自定义 API 类 |
| 数据模型 | `freezed` + `json_serializable` |
| 本地存储 | `hive` + `hive_flutter` |
| 路由导航 | `go_router` |
| 日志工具 | `logger` + `pretty_dio_logger` |

## 5. 构建与代码生成命令

在修改了 `models/`、`api/` 或 Riverpod providers 后，务必提示或执行以下命令更新生成代码：
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 6. 架构取舍备忘录（AI 决策参考）

### 6.1 标准开发路径
- **默认路径**：优先走 `Api -> Repo -> Provider -> UI` 的标准链路
- **极简降级**：如果确信某个单接口既无本地缓存要求，也不存在任何跨页面数据复用，允许极其轻量的直连（但为了统一性，依然建议封装入 Repo）
- **禁止过度设计**：不要为了"未来可能的扩展"而提前抽象，遵循 YAGNI 原则（You Aren't Gonna Need It）

### 6.2 代码生成工具使用指南

本项目提供 AI 辅助的代码生成工具（Skills），根据场景灵活选择：

#### 简单场景：一键生成完整模块
```bash
/gen-module user
# 适用于：标准 CRUD，1 Page = 1 API
# 生成：API + Repository + Model + Page + Provider
```

#### 复杂场景：灵活组合生成
```bash
# 步骤 1：分别生成多个数据层
/gen-api user
/gen-api order
/gen-api address

# 步骤 2：生成组合页面
/gen-page profile
# 选择：需要状态管理
# 生成的 Provider 模板包含详细注释，指导如何组合多个 Repository
```

#### 纯 UI 场景：无需数据层
```bash
/gen-page about
# 选择：不需要状态管理
# 生成：纯 StatelessWidget 页面
```

#### 后期维护：更新字段
```bash
/gen-model user
# 粘贴包含新字段的完整 JSON
# 只更新 Model，不影响其他文件
```

#### API 层响应解析规范
- 生成的 API 方法是**通用模板**，需根据后端文档手动调整：
  - 接口路径（如 `/v1/user/login`）
  - 请求参数名（如 `account` vs `username`）
  - 响应解析（如是否有外层 `{ "code": 200, "data": {...} }` 包装）
- 示例：
  ```dart
  // 后端返回：{ "code": 200, "data": { "id": "123", ... } }
  return UserModel.fromJson(response.data['data']);
  
  // 后端直接返回：{ "id": "123", ... }
  return UserModel.fromJson(response.data);
  ```

### 6.3 决策矩阵

| 场景 | 推荐工具 | 原因 |
|------|---------|------|
| 简单 CRUD（1:1:1） | `/gen-module` | 一键生成，节省时间 |
| 复杂页面（1 Page = 多 API） | `/gen-api` + `/gen-page` | 灵活组合，避免冗余 |
| 纯静态页面 | `/gen-page` (无状态) | 无需 Provider |
| 后期新增字段 | `/gen-model` | 只更新 Model |
| 需要聚合状态 | 手动创建 Freezed 类 | 类型安全，避免动态类型 |

## 7. 全局错误处理机制

### 7.1 核心设计原则
项目采用**策略模式 + 注册表模式**统一处理全局特殊错误码（如账号冲突、权限失效等），避免业务代码散落 if-else 判断。

### 7.2 架构流程

```text
业务接口响应 → BusinessResponseInterceptor（拦截器）
                ↓ 错误码映射
             GlobalHandledException（异常对象）
                ↓ 推送到全局
         GlobalErrorProvider（全局错误流）
                ↓ 监听处理
         GlobalErrorHandler（策略处理器）
                ↓ 执行动作
      UI 弹窗/跳转/清理数据等
```

### 7.3 各层职责

#### 错误码常量（`core/constants/error_codes.dart`）
- 集中管理所有特殊业务错误码
- 示例：
  ```dart
  class BusinessErrorCode {
    static const int accountConflict = 74015; // 账号冲突
    static const int tokenExpired = 74016;    // Token 过期
  }
  ```

#### 业务异常类（`core/exceptions/business_exceptions.dart`）
- 所有全局异常必须继承 `GlobalHandledException`
- 携带业务上下文数据（如设备信息、登录时间）
- 示例：
  ```dart
  class AccountConflictException extends GlobalHandledException {
    final String latestDevice;
    final String latestLoginTime;
    
    AccountConflictException({
      required this.latestDevice,
      required this.latestLoginTime,
      required super.message,
    });
  }
  ```

#### 拦截器映射（`core/dio/interceptors/business_response_interceptor.dart`）
- **核心原则**：使用 Map 映射替代 if-else，新增错误码只需添加映射项
- 责任：
  1. 拦截业务接口响应（`{IsSuccess, ErrorCode, Data, Message}`）
  2. 查表匹配错误码 → 工厂函数创建异常对象
  3. 推送到 `GlobalErrorProvider`（除 logout 接口）
  4. 转换为 `DioException` 向上抛出（供 Provider 层处理）
- 示例：
  ```dart
  static final _errorCodeMap = <int, GlobalHandledException Function(Map<String, dynamic>)>{
    BusinessErrorCode.accountConflict: (data) => AccountConflictException(
      latestDevice: data['LatestDevice'] ?? '未知设备',
      latestLoginTime: _formatTime(data['LatestLoginTime'] ?? ''),
      message: '账号在其他设备登录',
    ),
  };
  ```

#### 全局错误流（`providers/global/global_error_provider.dart`）
- 基于 `StreamController` 实现事件流
- 责任：接收拦截器推送的异常，分发给所有监听器
- 示例：
  ```dart
  @riverpod
  class GlobalError extends _$GlobalError {
    final _controller = StreamController<GlobalHandledException>.broadcast();
    
    Stream<GlobalHandledException> get stream => _controller.stream;
    
    void notify(GlobalHandledException error) {
      _controller.add(error);
    }
  }
  ```

#### 错误处理器（`core/handlers/global_error_handler.dart`）
- **核心原则**：策略模式，每个错误码对应一个 Handler
- 责任：执行具体的业务逻辑（弹窗、跳转、清理数据）
- 示例：
  ```dart
  class AccountConflictHandler extends GlobalErrorHandler<AccountConflictException> {
    @override
    Future<void> handle(BuildContext context, WidgetRef ref, AccountConflictException error) async {
      await DialogUtil.showAlert(
        context,
        title: '账号冲突',
        content: '您的账号已在 ${error.latestDevice} 设备登录\n请重新登录',
      );
      context.go(AppConstants.routeLogin);
    }
  }
  ```

#### 处理器注册表（`core/handlers/global_error_handler_registry.dart`）
- 维护错误类型 → Handler 的映射关系
- 示例：
  ```dart
  class GlobalErrorHandlerRegistry {
    static final _handlers = <Type, GlobalErrorHandler>{
      AccountConflictException: AccountConflictHandler(),
      TokenExpiredException: TokenExpiredHandler(),
    };
    
    static GlobalErrorHandler? getHandler<T extends GlobalHandledException>() {
      return _handlers[T];
    }
  }
  ```

### 7.4 使用规范

#### 新增特殊错误码的标准流程
1. **定义错误码常量**（`error_codes.dart`）
   ```dart
   static const int tokenExpired = 74016;
   ```

2. **创建异常类**（`business_exceptions.dart`）
   ```dart
   class TokenExpiredException extends GlobalHandledException {
     TokenExpiredException({required super.message});
   }
   ```

3. **添加拦截器映射**（`business_response_interceptor.dart`）
   ```dart
   BusinessErrorCode.tokenExpired: (data) => TokenExpiredException(
     message: data['Message'] ?? 'Token 已过期',
   ),
   ```

4. **实现 Handler**（`handlers/` 目录）
   ```dart
   class TokenExpiredHandler extends GlobalErrorHandler<TokenExpiredException> {
     @override
     Future<void> handle(BuildContext context, WidgetRef ref, TokenExpiredException error) async {
       // 清理 Token、跳转登录等
     }
   }
   ```

5. **注册到 Registry**（`global_error_handler_registry.dart`）
   ```dart
   TokenExpiredException: TokenExpiredHandler(),
   ```

#### UI 层监听（在根 Widget 中）
```dart
ref.listen(globalErrorProvider, (previous, next) {
  final error = next; // StreamController 推送的异常
  final handler = GlobalErrorHandlerRegistry.getHandler(error.runtimeType);
  handler?.handle(context, ref, error);
});
```

### 7.5 设计优势
✅ **扩展性**：新增错误码只需添加映射，无需修改拦截器核心逻辑
✅ **单一职责**：拦截器只负责映射，Handler 负责 UI 逻辑
✅ **防重入**：全局 Provider 通过 `isProcessing` 标记避免重复弹窗
✅ **类型安全**：泛型确保 Handler 接收正确的异常类型
✅ **解耦**：业务错误处理与 Provider 层完全分离

## 8. 路由与状态同步规范

### 8.1 路由参数传递最佳实践

**核心原则**：使用 `go_router` 的 `extra` 参数传递标记，避免不必要的接口重复请求。

#### 典型场景：登录后跳转主页
**问题**：用户登录成功后，已获取最新用户数据，跳转到主页时不应再次请求相同接口。

**解决方案**：通过路由参数传递 `fromLogin` 标记
```dart
// 登录成功后跳转
context.go(
  AppConstants.routeMain,
  extra: {AppConstants.extraFromLogin: true},
);

// 主页根据来源判断是否刷新
class MainPage extends ConsumerStatefulWidget {
  final bool fromLogin;
  
  const MainPage({this.fromLogin = false, super.key});
  
  @override
  void initState() {
    super.initState();
    
    // 冷启动（直接打开主页）才刷新
    if (!widget.fromLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProvider.notifier).refresh();
      });
    }
    // 登录跳转过来的，数据已是最新，跳过刷新
  }
}
```

#### 路由配置示例
```dart
GoRoute(
  path: AppConstants.routeMain,
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    final fromLogin = extra?[AppConstants.extraFromLogin] as bool? ?? false;
    return MainPage(fromLogin: fromLogin);
  },
)
```

### 8.2 常量管理规范

**核心原则**：所有路由相关的字符串（路径、参数 key）必须在 `AppConstants` 中统一管理

```dart
class AppConstants {
  // 路由路径
  static const String routeMain = '/main';
  static const String routeLogin = '/login';
  
  // 路由参数 Key
  static const String extraFromLogin = 'fromLogin';
  static const String extraUserId = 'userId';
}
```

### 8.3 优势
✅ **避免重复请求**：同一数据不会在短时间内重复请求
✅ **提升用户体验**：页面切换更流畅，减少等待时间
✅ **类型安全**：通过常量避免拼写错误
✅ **易于维护**：路由参数统一管理，修改只需一处

---

## 9. 日志系统规范

### 9.1 核心原则

**禁止使用 `print()`，统一使用 `AppLogger`**

### 9.2 为什么不用 print

- ❌ `print()` 在 Release 模式仍会输出，影响性能
- ❌ 没有日志级别区分，无法筛选
- ❌ 无法按模块分类
- ❌ 不符合生产代码规范

### 9.3 AppLogger 工具类

**位置**：`lib/core/utils/app_logger.dart`

**特性**：
- ✅ 支持多级别日志（debug/info/warning/error）
- ✅ 支持 tag 分类，方便按模块筛选
- ✅ 统一前缀 `nblog`，快速筛选所有业务日志
- ✅ 自动美化输出（emoji + 颜色）
- ✅ Release 模式自动禁用 debug 日志

### 9.4 使用方法

#### 推荐用法（带 tag）
```dart
// 使用预定义的 tag 常量
AppLogger.d('开始预加载数据', tag: LogTag.preload);
AppLogger.i('用户登录成功', tag: LogTag.auth);
AppLogger.w('缓存未命中', tag: LogTag.storage);
AppLogger.e('网络请求失败', tag: LogTag.api, error: e, stackTrace: stackTrace);
```

#### 简单用法（不带 tag）
```dart
AppLogger.d('临时调试信息');
AppLogger.i('关键信息');
```

### 9.5 预定义的 Tag 常量

```dart
LogTag.preload   // 预加载
LogTag.storage   // 存储操作
LogTag.device    // 设备管理
LogTag.ui        // 界面渲染
LogTag.api       // 网络请求
LogTag.auth      // 认证相关
LogTag.home      // 首页
LogTag.login     // 登录
```

### 9.6 日志筛选技巧

#### 筛选所有业务日志
```bash
flutter logs | grep "nblog"
```

#### 筛选特定模块
```bash
# 只看预加载相关
flutter logs | grep "nblog.*\[PreLoadLog\]"

# 只看存储相关
flutter logs | grep "nblog.*\[StorageLog\]"

# 只看设备相关
flutter logs | grep "nblog.*\[DeviceLog\]"

# 看多个模块
flutter logs | grep -E "nblog.*\[(PreLoad|Storage|Device)Log\]"
```

#### 排除业务日志
```bash
flutter logs | grep -v "nblog"
```

### 9.7 日志输出格式

```
🐛 DEBUG   nblog [PreLoadLog] 🚀 开始预加载数据
↑  ↑       ↑     ↑            ↑
│  │       │     │            └─ 消息内容
│  │       │     └────────────── Tag（可选）
│  │       └──────────────────── nblog 统一前缀
│  └──────────────────────────── 日志级别
└─────────────────────────────── Logger 包自动添加的 emoji
```

### 9.8 开发规范

✅ **必须做**：
- 所有日志使用 `AppLogger`
- 重要模块必须带 tag
- 使用预定义的 `LogTag` 常量

❌ **不要做**：
- 不要使用 `print()`
- 不要硬编码 tag 字符串（用 `LogTag.xxx`）
- 不要在 Release 模式输出敏感信息

---

## 10. 缓存架构与性能优化

### 10.1 三层缓存架构

本项目采用**三层缓存架构**，实现最优的数据访问性能：

```
┌─────────────────────────────────────────┐
│  第 1 层：内存缓存 (inMemoryDevicesProvider)│
│  - 速度：0ms（瞬间）                      │
│  - 生命周期：App 运行期间                 │
│  - 用途：瞬间响应 UI，最高优先级           │
└─────────────────────────────────────────┘
              ↓ 无数据时
┌─────────────────────────────────────────┐
│  第 2 层：Hive 缓存 (DeviceStorage)       │
│  - 速度：~50ms（快速）                    │
│  - 生命周期：持久化                       │
│  - 用途：跨启动保持数据                   │
└─────────────────────────────────────────┘
              ↓ 无数据时
┌─────────────────────────────────────────┐
│  第 3 层：网络请求 (DeviceApi)            │
│  - 速度：~200ms（较慢）                   │
│  - 用途：获取最新数据                     │
└─────────────────────────────────────────┘
```

### 10.2 预加载机制

**位置**：`lib/main.dart` 中的 `_preloadData()`

**执行时机**：App 启动时，在 UI 渲染前同步执行

**职责**：
1. 读取 token 判断登录状态
2. 读取 LoginInit 获取当前防区 ID
3. **同步读取**当前防区的设备缓存（使用 `getDevicesSync`）
4. 将数据预设到 `inMemoryDevicesProvider`

**关键代码**：
```dart
// main() 中
final preloaded = _preloadData();

runApp(
  ProviderScope(
    overrides: [
      currentAreaIdStateProvider.overrideWith(...),  // 预设防区 ID
      inMemoryDevicesProvider.overrideWith(...),      // 预设设备数据
    ],
    child: const MyApp(),
  ),
);
```

**为什么需要预加载**：
- ✅ 保证首页渲染时数据已在内存
- ✅ 避免首页显示占位符或 loading
- ✅ 实现 0ms 的瞬间显示体验

### 10.3 DeviceProvider 缓存优化（重要！）

**优化时间**：2025-01-15

#### 问题背景

二次冷启动时，虽然 `main._preloadData` 已将数据预设到内存，但 `deviceProvider.build` 仍会重复读取 Hive，导致：
- ❌ 浪费 ~50ms
- ❌ 多余的磁盘 IO
- ❌ 重复的内存写入（3 次 → 应该只有 2 次）

#### 优化方案：三级缓存优先级检查

**文件**：`lib/pages/home/providers/device_provider.dart`

**核心逻辑**（必须遵守）：

```dart
@override
Future<List<DeviceModel>> build() async {
  final currentAreaId = ref.watch(currentAreaIdProvider);

  // 【优先级 1】先检查内存缓存（最快，0ms）⭐ 关键！
  final inMemoryDevices = ref.read(inMemoryDevicesProvider)[currentAreaId];
  if (inMemoryDevices != null && inMemoryDevices.isNotEmpty) {
    AppLogger.d('⚡️ 从内存缓存返回（瞬间显示）', tag: LogTag.device);
    _refreshInBackground(currentAreaId);  // 后台静默刷新
    return inMemoryDevices;
  }

  // 【优先级 2】内存没有，读取 Hive 缓存（~50ms）
  final hiveCached = await ref.read(deviceRepositoryProvider).getCachedDevices(currentAreaId);
  if (hiveCached != null && hiveCached.isNotEmpty) {
    AppLogger.d('✅ 从 Hive 缓存返回', tag: LogTag.device);
    _updateMemoryState(currentAreaId, hiveCached);
    _refreshInBackground(currentAreaId);
    return hiveCached;
  }

  // 【优先级 3】无任何缓存，请求接口（~200ms）
  final devices = await ref.read(deviceRepositoryProvider).refreshDevices(currentAreaId);
  _updateMemoryState(currentAreaId, devices);
  return devices;
}
```

#### 性能提升

| 指标 | 优化前 | 优化后 | 提升 |
|-----|--------|--------|------|
| 二次冷启动耗时 | ~300ms | ~50ms | ✅ 减少 250ms（83%）|
| Hive 读取次数 | 2 次 | 1 次 | ✅ 减少 50% |
| 内存写入次数 | 3 次 | 2 次 | ✅ 减少 33% |
| 用户感知延迟 | 有延迟 | 瞬间显示 | ✅ 体验提升 |

#### 适用场景

- ✅ **二次冷启动**（最常见）：从内存瞬间返回，0ms
- ✅ **热启动/防区切换**：从内存瞬间返回，0ms
- ✅ **首次启动**：从 Hive 或接口加载，自动建立缓存

#### 关键原则（不要违反！）

✅ **必须做**：
- 第一步必须检查 `inMemoryDevicesProvider`
- 有内存数据必须直接返回，不要读 Hive
- 保持后台刷新机制（`_refreshInBackground`）

❌ **不要做**：
- ❌ 不要跳过内存缓存检查
- ❌ 不要在 build 中直接读 Hive（除非内存无数据）
- ❌ 不要移除预加载逻辑
- ❌ 不要删除 `ProviderScope.overrides` 中的预设

### 10.4 数据流向

#### 冷启动流程
```
启动 → 预加载同步读 Hive (~50ms)
         ↓
      写入内存 (<1ms)
         ↓
    UI 从内存读取 (<1ms) → 瞬间显示
         ↓
    后台刷新 (~200ms)
         ↓
    更新内存 + 保存 Hive
```

#### 热启动/防区切换
```
UI 从内存读取 (<1ms) → 瞬间显示
         ↓
    后台刷新 (~200ms)
         ↓
    更新内存 + 保存 Hive
```

### 10.5 关键 Provider

- **`inMemoryDevicesProvider`**: 内存缓存，按防区 ID 存储 `Map<int, List<DeviceModel>>`
- **`currentAreaIdStateProvider`**: 当前选中的防区 ID
- **`deviceProvider`**: 设备列表的异步 Provider，实现三级缓存逻辑

### 10.6 验证日志

#### 正确的冷启动日志应该是：

```
[PreLoadLog] 🚀 开始预加载数据
[PreLoadLog] ✅ 成功加载 6 个设备
[StorageLog] 📖 getDevicesSync 同步读取  ← 唯一的 Hive 读取
[DeviceLog] ⚡️ 从内存缓存返回: 6 个设备  ← 关键！
[DeviceLog] 🔄 启动后台刷新
```

#### 如果看到这些日志，说明优化失效：

```
❌ [StorageLog] 📖 getDevices 读取防区...  ← 在 build 阶段不应该有！
❌ [DeviceLog] ✅ 从 Hive 缓存返回        ← 应该从内存返回！
```

### 10.7 性能优化历史

| 时间 | 优化内容 | 效果 | 提交 |
|-----|---------|------|------|
| 2025-01-15 | DeviceProvider 三级缓存优化 | 减少 250ms，提升 83% | - |

---

## 11. 重要注意事项

### 11.1 不要破坏的优化

以下是经过性能调优的关键逻辑，**不要随意修改**：

1. **预加载机制**（`main._preloadData`）
   - 不要改成异步
   - 不要跳过 `getDevicesSync`
   - 不要移除 `ProviderScope.overrides`

2. **DeviceProvider 的内存缓存优先级**
   - 不要跳过第一步的内存检查
   - 不要在有内存数据时还去读 Hive

3. **日志系统**
   - 不要使用 `print()`
   - 不要移除 `nblog` 前缀

### 11.2 添加新功能时的注意事项

#### 添加新的数据缓存时：
1. 优先考虑使用三层缓存架构
2. 在 `main._preloadData` 中预加载关键数据
3. 在 Provider 中先检查内存，再读 Hive
4. 保持后台刷新机制

#### 添加新的 Provider 时：
1. 考虑是否需要全局共享（放在 `providers/global/`）
2. 如果是页面级，放在对应页面的 `providers/` 目录
3. 使用 `AsyncValue` 统一处理异步状态

#### 添加日志时：
1. 使用 `AppLogger`，不要用 `print()`
2. 选择合适的 tag（优先使用 `LogTag` 预定义常量）
3. 选择合适的日志级别（debug/info/warning/error）

