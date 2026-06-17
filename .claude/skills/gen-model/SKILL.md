---
description: 从 JSON 快速生成 Freezed + json_serializable 数据模型。支持自动解析 JSON 结构并生成对应的 Dart 类。
---

# gen-model

从 JSON 自动生成 Freezed 数据模型，节省手写样板代码的时间。

## 使用方式

### 方式 1：提供 JSON 数据

```
/gen-model user

然后提供 JSON：
{
  "id": "123",
  "name": "John",
  "email": "john@example.com",
  "age": 25
}
```

### 方式 2：直接描述字段

```
/gen-model user id:String name:String email:String age:int
```

## 生成位置

```
lib/models/{name}/{name}_model.dart
```

## 生成模板

### 基础模型

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name}_model.freezed.dart';
part '{name}_model.g.dart';

@freezed
class {Name}Model with _${Name}Model {
  const factory {Name}Model({
    required String id,
    required String name,
    String? email,
    @Default(0) int age,
  }) = _{Name}Model;

  factory {Name}Model.fromJson(Map<String, dynamic> json) =>
      _${Name}ModelFromJson(json);
}
```

### 嵌套模型

如果 JSON 中包含嵌套对象，会自动生成对应的子模型：

```dart
// 输入 JSON:
{
  "id": "1",
  "user": {
    "name": "John",
    "email": "john@example.com"
  }
}

// 生成两个模型：
@freezed
class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    required String name,
    required String email,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
}

@freezed
class ParentModel with _$ParentModel {
  const factory ParentModel({
    required String id,
    required UserInfoModel user,
  }) = _ParentModel;

  factory ParentModel.fromJson(Map<String, dynamic> json) =>
      _$ParentModelFromJson(json);
}
```

## 字段类型映射

| JSON 类型 | Dart 类型 |
|-----------|----------|
| "string" | String |
| 123 | int |
| 1.5 | double |
| true | bool |
| [] | List<dynamic> |
| {} | Map<String, dynamic> |
| null | String? (可空) |

## 特殊注解支持

### 1. JSON Key 映射

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: 'user_id') required String id,
    @JsonKey(name: 'user_name') required String name,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### 2. 默认值

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    @Default('Guest') String name,
    @Default(0) int age,
    @Default([]) List<String> tags,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

## 生成后操作

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 注意事项

- 复杂嵌套结构建议手动调整
- JSON 字段命名如果不是驼峰式，需要添加 `@JsonKey` 注解
- 列表类型需要明确泛型（如 `List<String>`）
- 可空字段用 `String?`，必填字段用 `required`
