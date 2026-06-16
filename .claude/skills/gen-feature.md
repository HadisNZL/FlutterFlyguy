# gen-feature

快速生成 Clean Architecture Feature 脚手架

## 用法

```
/gen-feature <feature_name>
```

## 参数

- `feature_name`: Feature 名称（如 auth, user, product）

## 功能

自动创建完整的三层架构文件：

### Domain Layer（领域层）
- `lib/domain/entities/{feature}_entity.dart` - 实体类（freezed）
- `lib/domain/repositories/{feature}_repository.dart` - Repository 接口

### Data Layer（数据层）
- `lib/data/models/{feature}_model.dart` - 数据模型（freezed + json）
- `lib/data/datasources/remote/{feature}_api.dart` - API 接口（retrofit）
- `lib/data/repositories/{feature}_repository_impl.dart` - Repository 实现

### Presentation Layer（展示层）
- `lib/presentation/providers/{feature}_provider.dart` - Riverpod Provider
- `lib/presentation/pages/{feature}_page.dart` - 页面组件

## 示例

```bash
/gen-feature auth
# 生成: auth_entity, auth_repository, auth_model, auth_api, auth_repository_impl, auth_provider, auth_page

/gen-feature user  
# 生成: user_entity, user_repository, user_model, user_api, user_repository_impl, user_provider, user_page
```

## 注意事项

1. 生成后需要运行代码生成:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Provider 中需要手动注入 Repository 依赖

3. 需要安装 `dartz` 包用于错误处理:
   ```bash
   flutter pub add dartz
   ```
