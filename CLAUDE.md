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
│   ├── constants/          # 全局常量（颜色、尺寸、接口地址枚举）
│   ├── extensions/         # 通用扩展方法（String, DateTime 等）
│   └── utils/              # 无状态的纯工具函数（如格式化、Toast等）
├── api/                    # 纯网络请求接口层（Dio 直接实现）
├── repositories/           # 数据聚合层（只有实现类，无抽象接口）
├── models/                 # 唯一的数据实体层（按模块分包）
│   ├── user/               # 业务模型（如 user_model.dart）
│   └── states/             # 聚合状态类（如 profile_state.dart，用于组合多个 Model）
├── providers/              # Provider 层
│   └── global/             # 全局共享状态 Provider（用户信息、购物车等）
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
