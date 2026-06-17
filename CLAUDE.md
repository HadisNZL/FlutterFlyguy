# CLAUDE.md - 项目架构与 AI 编程规范指南

本项目采用 **实用型 MVVM (Plan B)** 架构设计，核心目标是在"开发效率"与"商业级项目的可维护性"之间取得完美平衡。
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
├── pages/                  # 视图页面层（按业务模块分包）
├── widgets/                # 全局高频复用的基础小组件
└── main.dart               # 应用入口
```

## 3. 各层级严格编程纪律

### 3.1 视图模型层 (Riverpod Providers)
- **角色**：界面的 ViewModel，负责承载界面的 `loading/error/data` 状态
- **规范**：
  - 严禁引入 `dartz` 或自定义 `Either`。必须**原生且唯一**地使用 Riverpod 的 `AsyncValue` 来处理异步网络状态
  - 优先使用 `@riverpod` 代码生成器语法来定义 Provider
  - Provider 文件统一放在对应页面的同级 `providers/` 目录
  - Provider 只负责"调用 Repository -> 抛出 State给 UI"，不要在 Provider 内写繁琐的 JSON 字段拼接

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
- **默认路径**：优先走 `Api -> Repo -> Provider -> UI` 的标准链路
- **极简降级**：如果确信某个单接口既无本地缓存要求，也不存在任何跨页面数据复用，允许极其轻量的直连（但为了统一性，依然建议封装入 Repo）
- **禁止过度设计**：不要为了"未来可能的扩展"而提前抽象，遵循 YAGNI 原则（You Aren't Gonna Need It）
