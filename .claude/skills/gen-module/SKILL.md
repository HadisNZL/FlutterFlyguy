---
description: 快速生成完整功能模块（API + Repository + Model + Page）。适用于创建新的业务模块（如 auth、user、product 等）。
---

# gen-module

生成完整的功能模块，包含 API、Repository、Model 和 Page 四个核心文件。

## 使用方式

```bash
/gen-module auth      # 生成认证模块
/gen-module user      # 生成用户模块
/gen-module product   # 生成商品模块
```

## 生成的文件结构

以 `auth` 为例，将生成：

```
lib/
├── api/auth_api.dart                    # Dio API 接口
├── repositories/auth_repository.dart    # 数据聚合层
├── models/auth/auth_model.dart          # Freezed 模型
└── pages/auth/
    ├── auth_page.dart                   # 页面
    └── providers/auth_provider.dart     # Riverpod Provider
```

## 代码模板

### 1. API 层 (`api/{name}_api.dart`)

```dart
import 'package:dio/dio.dart';
import '../models/{name}/{name}_model.dart';

class {Name}Api {
  {Name}Api(this._dio);

  final Dio _dio;

  Future<{Name}Model> get{Name}(String id) async {
    final response = await _dio.get('/{names}/$id');
    return {Name}Model.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<{Name}Model>> get{Name}s() async {
    final response = await _dio.get('/{names}');
    return (response.data as List)
        .map((json) => {Name}Model.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

### 2. Repository 层 (`repositories/{name}_repository.dart`)

```dart
import '../api/{name}_api.dart';
import '../models/{name}/{name}_model.dart';

class {Name}Repository {
  {Name}Repository(this._api);

  final {Name}Api _api;

  Future<{Name}Model> get{Name}(String id) async {
    return await _api.get{Name}(id);
  }

  Future<List<{Name}Model>> get{Name}s() async {
    return await _api.get{Name}s();
  }
}
```

### 3. Model 层 (`models/{name}/{name}_model.dart`)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name}_model.freezed.dart';
part '{name}_model.g.dart';

@freezed
class {Name}Model with _${Name}Model {
  const factory {Name}Model({
    required String id,
    required String name,
  }) = _{Name}Model;

  factory {Name}Model.fromJson(Map<String, dynamic> json) =>
      _${Name}ModelFromJson(json);
}
```

### 4. Provider 层 (`pages/{name}/providers/{name}_provider.dart`)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/dio/dio_client.dart';
import '../../../api/{name}_api.dart';
import '../../../repositories/{name}_repository.dart';
import '../../../models/{name}/{name}_model.dart';

part '{name}_provider.g.dart';

@riverpod
{Name}Api {name}Api(ref) => {Name}Api(DioClient.create());

@riverpod
{Name}Repository {name}Repository(ref) =>
    {Name}Repository(ref.watch({name}ApiProvider));

@riverpod
class {Name}Notifier extends _{Name}Notifier {
  @override
  Future<{Name}Model?> build() async => null;

  Future<void> load{Name}(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read({name}RepositoryProvider).get{Name}(id),
    );
  }
}
```

### 5. Page 层 (`pages/{name}/{name}_page.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/{name}_provider.dart';

class {Name}Page extends ConsumerWidget {
  const {Name}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch({name}NotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('{Name}')),
      body: state.when(
        data: (data) => Center(
          child: Text(data?.name ?? 'No data'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

## 生成后操作

1. **运行代码生成**：
```bash
dart run build_runner build --delete-conflicting-outputs
```

2. **根据实际 API 调整**：
   - 修改 API 路径
   - 调整 Model 字段
   - 补充业务逻辑

## 注意事项

- 命名使用 `snake_case`（文件名）和 `PascalCase`（类名）
- Model 字段需要根据实际 API 响应调整
- Provider 使用 `@riverpod` 代码生成
- Repository 只是实现类，没有抽象接口
