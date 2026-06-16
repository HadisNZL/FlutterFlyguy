#!/usr/bin/env node
/**
 * /gen-feature - 快速生成 Clean Architecture Feature 脚手架
 *
 * 用法: /gen-feature <feature_name>
 * 示例: /gen-feature auth
 */

const featureName = process.argv[2];

if (!featureName) {
  console.error('错误: 请提供 feature 名称');
  console.log('用法: /gen-feature <feature_name>');
  process.exit(1);
}

const pascalCase = featureName.charAt(0).toUpperCase() + featureName.slice(1);
const snakeCase = featureName.toLowerCase();

console.log(`🚀 正在生成 Feature: ${featureName}...`);
console.log('');

// 定义要创建的文件模板
const templates = {
  // Domain Entity
  entity: {
    path: `lib/domain/entities/${snakeCase}_entity.dart`,
    content: `import 'package:freezed_annotation/freezed_annotation.dart';

part '${snakeCase}_entity.freezed.dart';

@freezed
class ${pascalCase}Entity with _$${pascalCase}Entity {
  const factory ${pascalCase}Entity({
    required String id,
  }) = _${pascalCase}Entity;
}
`
  },

  // Domain Repository Interface
  repositoryInterface: {
    path: `lib/domain/repositories/${snakeCase}_repository.dart`,
    content: `import 'package:dartz/dartz.dart';
import '../entities/${snakeCase}_entity.dart';

abstract class ${pascalCase}Repository {
  Future<Either<Exception, ${pascalCase}Entity>> get${pascalCase}(String id);
}
`
  },

  // Data Model
  model: {
    path: `lib/data/models/${snakeCase}_model.dart`,
    content: `import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/${snakeCase}_entity.dart';

part '${snakeCase}_model.freezed.dart';
part '${snakeCase}_model.g.dart';

@freezed
class ${pascalCase}Model with _$${pascalCase}Model {
  const ${pascalCase}Model._();

  const factory ${pascalCase}Model({
    required String id,
  }) = _${pascalCase}Model;

  factory ${pascalCase}Model.fromJson(Map<String, dynamic> json) =>
      _$${pascalCase}ModelFromJson(json);

  ${pascalCase}Entity toEntity() => ${pascalCase}Entity(
        id: id,
      );
}
`
  },

  // Data Source (Retrofit API)
  dataSource: {
    path: `lib/data/datasources/remote/${snakeCase}_api.dart`,
    content: `import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/${snakeCase}_model.dart';

part '${snakeCase}_api.g.dart';

@RestApi()
abstract class ${pascalCase}Api {
  factory ${pascalCase}Api(Dio dio, {String baseUrl}) = _${pascalCase}Api;

  @GET('/${snakeCase}s/{id}')
  Future<${pascalCase}Model> get${pascalCase}(@Path('id') String id);
}
`
  },

  // Repository Implementation
  repositoryImpl: {
    path: `lib/data/repositories/${snakeCase}_repository_impl.dart`,
    content: `import 'package:dartz/dartz.dart';
import '../../domain/entities/${snakeCase}_entity.dart';
import '../../domain/repositories/${snakeCase}_repository.dart';
import '../datasources/remote/${snakeCase}_api.dart';

class ${pascalCase}RepositoryImpl implements ${pascalCase}Repository {
  final ${pascalCase}Api _api;

  ${pascalCase}RepositoryImpl(this._api);

  @override
  Future<Either<Exception, ${pascalCase}Entity>> get${pascalCase}(String id) async {
    try {
      final model = await _api.get${pascalCase}(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
`
  },

  // Provider
  provider: {
    path: `lib/presentation/providers/${snakeCase}_provider.dart`,
    content: `import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/${snakeCase}_entity.dart';
import '../../domain/repositories/${snakeCase}_repository.dart';

final ${snakeCase}Provider = StateNotifierProvider<${pascalCase}Notifier, AsyncValue<${pascalCase}Entity?>>((ref) {
  // TODO: 注入 Repository
  throw UnimplementedError('需要配置 Repository Provider');
});

class ${pascalCase}Notifier extends StateNotifier<AsyncValue<${pascalCase}Entity?>> {
  final ${pascalCase}Repository _repository;

  ${pascalCase}Notifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> load${pascalCase}(String id) async {
    state = const AsyncValue.loading();
    final result = await _repository.get${pascalCase}(id);
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (entity) => state = AsyncValue.data(entity),
    );
  }
}
`
  },

  // Page
  page: {
    path: `lib/presentation/pages/${snakeCase}_page.dart`,
    content: `import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/${snakeCase}_provider.dart';

class ${pascalCase}Page extends ConsumerWidget {
  const ${pascalCase}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${snakeCase}Provider);

    return Scaffold(
      appBar: AppBar(title: const Text('${pascalCase}')),
      body: state.when(
        data: (entity) => Center(
          child: Text(entity?.id ?? 'No data'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: \$error')),
      ),
    );
  }
}
`
  },
};

// 输出创建的文件清单
console.log('📁 将创建以下文件:');
console.log('');
Object.entries(templates).forEach(([key, {path}]) => {
  console.log(`  ${path}`);
});
console.log('');
console.log('✅ 模板已准备好，请确认后执行创建操作');
console.log('');
console.log('⚠️  注意: 需要添加 dartz 依赖用于错误处理');
console.log('   运行: flutter pub add dartz');
console.log('');
console.log('🔧 创建文件后需要运行:');
console.log('   flutter pub run build_runner build --delete-conflicting-outputs');

// 输出 JSON 格式供 Claude 解析
console.log('');
console.log('---TEMPLATE_DATA---');
console.log(JSON.stringify(templates, null, 2));
