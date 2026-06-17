---
description: 快速生成 Clean Architecture Feature 脚手架。当用户想创建新的功能模块（如 user、auth、product）时使用此 skill。
---

# gen-feature

生成完整的 Flutter Clean Architecture Feature 代码结构。

## 第一步：确定 feature 名称

请告诉我要生成哪个 feature？例如：
- `user` - 用户模块
- `auth` - 认证模块  
- `product` - 商品模块

如果你已经在消息中提到了名称（如 "/gen-feature user"），我会直接使用它。

## 第二步：生成文件

我将创建以下文件结构（以 `user` 为例）：

### Domain Layer（领域层）
- `lib/domain/entities/user_entity.dart` - Freezed 实体类
- `lib/domain/repositories/user_repository.dart` - Repository 接口

### Data Layer（数据层）
- `lib/data/models/user_model.dart` - Freezed + JSON 数据模型
- `lib/data/datasources/remote/user_api.dart` - Retrofit API 接口
- `lib/data/repositories/user_repository_impl.dart` - Repository 实现

### Presentation Layer（展示层）
- `lib/presentation/providers/user_provider.dart` - Riverpod Provider
- `lib/presentation/pages/user_page.dart` - 页面组件

## 代码模板规范

### Entity (Freezed)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
  }) = _UserEntity;
}
```

### Repository Interface
```dart
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Exception, UserEntity>> getUser(String id);
}
```

### Model (Freezed + JSON)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(id: id);
}
```

### API (Retrofit)
```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/user_model.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  @GET('/users/{id}')
  Future<UserModel> getUser(@Path('id') String id);
}
```

### Repository Implementation
```dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_api.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi _api;

  UserRepositoryImpl(this._api);

  @override
  Future<Either<Exception, UserEntity>> getUser(String id) async {
    try {
      final model = await _api.getUser(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
```

### Provider (Riverpod)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserEntity?>>((ref) {
  // TODO: 注入 Repository
  throw UnimplementedError('需要配置 Repository Provider');
});

class UserNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> loadUser(String id) async {
    state = const AsyncValue.loading();
    final result = await _repository.getUser(id);
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (entity) => state = AsyncValue.data(entity),
    );
  }
}
```

### Page (Flutter Widget)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: state.when(
        data: (entity) => Center(
          child: Text(entity?.id ?? 'No data'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

## 生成后操作

完成生成后，需要运行代码生成：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

如果项目中还没有安装 `dartz` 包（用于错误处理），需要先安装：

```bash
flutter pub add dartz
```

## 注意事项

1. **命名规则**：所有文件名使用 `snake_case`，类名使用 `PascalCase`
2. **依赖注入**：生成的 Provider 中需要手动注入 Repository 依赖
3. **代码生成**：必须运行 build_runner 才能生成 `.g.dart` 和 `.freezed.dart` 文件
4. **架构约束**：严格遵循 Clean Architecture 分层，Domain 层不依赖 Data 和 Presentation 层
