import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../utils/app_logger.dart';

/// 通用的 Hive JSON 存储工具类
///
/// 支持多种数据类型的存储：
/// - List<T>: 列表数据
/// - T: 单个对象
/// - Map<String, T>: 键值对集合
/// - 简单类型: String, int, bool, double
///
/// 使用 JSON 字符串格式避免 Hive 的类型转换问题
///
/// 使用示例：
/// ```dart
/// // 列表存储
/// final storage = HiveJsonStorage<DeviceModel>(
///   boxName: 'devices',
///   fromJson: DeviceModel.fromJson,
///   toJson: (model) => model.toJson(),
/// );
/// await storage.saveList('devices_1308', devices);
/// final devices = await storage.getList('devices_1308');
///
/// // 单对象存储
/// await storage.saveSingle('current_device', device);
/// final device = await storage.getSingle('current_device');
///
/// // Map 存储
/// await storage.saveMap('devices_by_area', {1308: [device1], 5678: [device2]});
/// final map = await storage.getMap('devices_by_area');
/// ```
class HiveJsonStorage<T> {
  HiveJsonStorage({
    required this.boxName,
    required this.fromJson,
    required this.toJson,
  });
  final String boxName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  // ==================== 列表存储 ====================

  /// 保存列表数据（存储为 JSON 字符串）
  ///
  /// 参数：
  /// - key: 存储的键
  /// - items: 要保存的列表
  Future<void> saveList(String key, List<T> items) async {
    try {
      final box = await Hive.openBox<String>(boxName);
      final jsonString = jsonEncode(items.map(toJson).toList());
      await box.put(key, jsonString);
      AppLogger.d('✅ [HiveJsonStorage] 保存列表成功: $boxName/$key, ${items.length} 条数据', tag: LogTag.storage);
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 保存列表失败: $e', tag: LogTag.storage);
      rethrow;
    }
  }

  /// 获取列表数据（从 JSON 字符串解析）
  ///
  /// 参数：
  /// - key: 存储的键
  ///
  /// 返回：
  /// - 有数据：返回解析后的列表
  /// - 无数据：返回 null
  Future<List<T>?> getList(String key) async {
    try {
      final box = await Hive.openBox<String>(boxName);
      final jsonString = box.get(key);

      if (jsonString == null) {
        AppLogger.d('📖 [HiveJsonStorage] 无缓存: $boxName/$key', tag: LogTag.storage);
        return null;
      }

      final list = jsonDecode(jsonString) as List;
      final items = list
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.d('✅ [HiveJsonStorage] 读取列表成功: $boxName/$key, ${items.length} 条数据', tag: LogTag.storage);
      return items;
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 读取列表失败: $e', tag: LogTag.storage);
      return null;
    }
  }

  /// 同步读取列表数据（用于 main() 预加载）
  ///
  /// 注意：Box 必须已经在外部打开
  ///
  /// 参数：
  /// - key: 存储的键
  ///
  /// 返回：
  /// - 有数据：返回解析后的列表
  /// - 无数据：返回 null
  List<T>? getListSync(String key) {
    try {
      final box = Hive.box<String>(boxName);
      final jsonString = box.get(key);

      if (jsonString == null) {
        AppLogger.d('📖 [HiveJsonStorage] 同步读取列表无缓存: $boxName/$key', tag: LogTag.storage);
        return null;
      }

      final list = jsonDecode(jsonString) as List;
      final items = list
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.d('✅ [HiveJsonStorage] 同步读取列表成功: $boxName/$key, ${items.length} 条数据', tag: LogTag.storage);
      return items;
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 同步读取列表失败: $e', tag: LogTag.storage);
      return null;
    }
  }

  // ==================== 单对象存储 ====================

  /// 保存单个对象（存储为 JSON 字符串）
  ///
  /// 参数：
  /// - key: 存储的键
  /// - item: 要保存的对象
  Future<void> saveSingle(String key, T item) async {
    try {
      final box = await Hive.openBox<String>(boxName);
      final jsonString = jsonEncode(toJson(item));
      await box.put(key, jsonString);
      AppLogger.d('✅ [HiveJsonStorage] 保存对象成功: $boxName/$key', tag: LogTag.storage);
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 保存对象失败: $e', tag: LogTag.storage);
      rethrow;
    }
  }

  /// 获取单个对象（从 JSON 字符串解析）
  ///
  /// 参数：
  /// - key: 存储的键
  ///
  /// 返回：
  /// - 有数据：返回解析后的对象
  /// - 无数据：返回 null
  Future<T?> getSingle(String key) async {
    try {
      final box = await Hive.openBox<String>(boxName);
      final jsonString = box.get(key);

      if (jsonString == null) {
        AppLogger.d('📖 [HiveJsonStorage] 无缓存: $boxName/$key', tag: LogTag.storage);
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final item = fromJson(json);

      AppLogger.d('✅ [HiveJsonStorage] 读取对象成功: $boxName/$key', tag: LogTag.storage);
      return item;
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 读取对象失败: $e', tag: LogTag.storage);
      return null;
    }
  }

  /// 同步读取单个对象（用于 main() 预加载）
  ///
  /// 注意：Box 必须已经在外部打开
  T? getSingleSync(String key) {
    try {
      final box = Hive.box<String>(boxName);
      final jsonString = box.get(key);

      if (jsonString == null) {
        AppLogger.d('📖 [HiveJsonStorage] 同步读取对象无缓存: $boxName/$key', tag: LogTag.storage);
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final item = fromJson(json);

      AppLogger.d('✅ [HiveJsonStorage] 同步读取对象成功: $boxName/$key', tag: LogTag.storage);
      return item;
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 同步读取对象失败: $e', tag: LogTag.storage);
      return null;
    }
  }

  // ==================== Map 存储 ====================

  /// 保存 Map 数据（存储为 JSON 字符串）
  ///
  /// 支持 Map<String, T> 和 Map<int, T>
  ///
  /// 参数：
  /// - key: 存储的键
  /// - map: 要保存的 Map
  Future<void> saveMap(String key, Map<dynamic, T> map) async {
    try {
      final box = await Hive.openBox<String>(boxName);
      // 将 Map 的 value 转换为 JSON
      final jsonMap = map.map((k, v) => MapEntry(k.toString(), toJson(v)));
      final jsonString = jsonEncode(jsonMap);
      await box.put(key, jsonString);
      AppLogger.d('✅ [HiveJsonStorage] 保存 Map 成功: $boxName/$key, ${map.length} 条数据', tag: LogTag.storage);
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 保存 Map 失败: $e', tag: LogTag.storage);
      rethrow;
    }
  }

  /// 获取 Map 数据（从 JSON 字符串解析）
  ///
  /// 支持 Map<String, T> 和 Map<int, T>
  ///
  /// 参数：
  /// - key: 存储的键
  /// - keyConverter: 键的转换函数（如 int.parse）
  ///
  /// 返回：
  /// - 有数据：返回解析后的 Map
  /// - 无数据：返回 null
  Future<Map<K, T>?> getMap<K>(
    String key, {
    K Function(String)? keyConverter,
  }) async {
    try {
      final box = await Hive.openBox<String>(boxName);
      final jsonString = box.get(key);

      if (jsonString == null) {
        AppLogger.d('📖 [HiveJsonStorage] 无缓存: $boxName/$key', tag: LogTag.storage);
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final result = <K, T>{};

      jsonMap.forEach((k, v) {
        final convertedKey = keyConverter != null ? keyConverter(k) : k as K;
        result[convertedKey] = fromJson(v as Map<String, dynamic>);
      });

      AppLogger.d(
        '✅ [HiveJsonStorage] 读取 Map 成功: $boxName/$key, ${result.length} 条数据',
        tag: LogTag.storage,
      );
      return result;
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 读取 Map 失败: $e', tag: LogTag.storage);
      return null;
    }
  }

  /// 同步读取 Map 数据（用于 main() 预加载）
  ///
  /// 注意：Box 必须已经在外部打开
  Map<K, T>? getMapSync<K>(String key, {K Function(String)? keyConverter}) {
    try {
      final box = Hive.box<String>(boxName);
      final jsonString = box.get(key);

      if (jsonString == null) {
        AppLogger.d('📖 [HiveJsonStorage] 同步读取 Map 无缓存: $boxName/$key', tag: LogTag.storage);
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final result = <K, T>{};

      jsonMap.forEach((k, v) {
        final convertedKey = keyConverter != null ? keyConverter(k) : k as K;
        result[convertedKey] = fromJson(v as Map<String, dynamic>);
      });

      AppLogger.d(
        '✅ [HiveJsonStorage] 同步读取 Map 成功: $boxName/$key, ${result.length} 条数据',
        tag: LogTag.storage,
      );
      return result;
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 同步读取 Map 失败: $e', tag: LogTag.storage);
      return null;
    }
  }

  // ==================== 通用操作 ====================

  /// 删除指定 key 的数据
  Future<void> delete(String key) async {
    try {
      final box = await Hive.openBox<String>(boxName);
      await box.delete(key);
      AppLogger.d('✅ [HiveJsonStorage] 删除成功: $boxName/$key', tag: LogTag.storage);
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 删除失败: $e', tag: LogTag.storage);
      rethrow;
    }
  }

  /// 清空所有数据
  Future<void> clearAll() async {
    try {
      final box = await Hive.openBox<String>(boxName);
      await box.clear();
      AppLogger.d('✅ [HiveJsonStorage] 清空成功: $boxName', tag: LogTag.storage);
    } catch (e) {
      AppLogger.e('❌ [HiveJsonStorage] 清空失败: $e', tag: LogTag.storage);
      rethrow;
    }
  }

  /// 检查 key 是否存在
  Future<bool> containsKey(String key) async {
    final box = await Hive.openBox<String>(boxName);
    return box.containsKey(key);
  }

  /// 获取所有 keys
  Future<List<String>> getAllKeys() async {
    final box = await Hive.openBox<String>(boxName);
    return box.keys.cast<String>().toList();
  }
}

// ==================== 简单类型存储工具 ====================

/// 简单类型存储工具（String, int, bool, double）
///
/// 用于存储基本类型数据，如用户偏好、开关状态等
///
/// 使用示例：
/// ```dart
/// final prefs = HivePreferences(boxName: 'preferences');
///
/// await prefs.setString('theme', 'dark');
/// final theme = await prefs.getString('theme');
///
/// await prefs.setInt('version', 123);
/// await prefs.setBool('first_launch', false);
/// ```
class HivePreferences {
  HivePreferences({required this.boxName});
  final String boxName;

  // String
  Future<void> setString(String key, String value) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put(key, value);
  }

  Future<String?> getString(String key) async {
    final box = await Hive.openBox<String>(boxName);
    return box.get(key);
  }

  String? getStringSync(String key) {
    final box = Hive.box<String>(boxName);
    return box.get(key);
  }

  // int
  Future<void> setInt(String key, int value) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put(key, value.toString());
  }

  Future<int?> getInt(String key) async {
    final box = await Hive.openBox<String>(boxName);
    final value = box.get(key);
    return value != null ? int.tryParse(value) : null;
  }

  int? getIntSync(String key) {
    final box = Hive.box<String>(boxName);
    final value = box.get(key);
    return value != null ? int.tryParse(value) : null;
  }

  // bool
  Future<void> setBool(String key, bool value) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put(key, value.toString());
  }

  Future<bool?> getBool(String key) async {
    final box = await Hive.openBox<String>(boxName);
    final value = box.get(key);
    return value != null ? value == 'true' : null;
  }

  bool? getBoolSync(String key) {
    final box = Hive.box<String>(boxName);
    final value = box.get(key);
    return value != null ? value == 'true' : null;
  }

  // double
  Future<void> setDouble(String key, double value) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put(key, value.toString());
  }

  Future<double?> getDouble(String key) async {
    final box = await Hive.openBox<String>(boxName);
    final value = box.get(key);
    return value != null ? double.tryParse(value) : null;
  }

  double? getDoubleSync(String key) {
    final box = Hive.box<String>(boxName);
    final value = box.get(key);
    return value != null ? double.tryParse(value) : null;
  }

  // 删除
  Future<void> remove(String key) async {
    final box = await Hive.openBox<String>(boxName);
    await box.delete(key);
  }

  // 清空
  Future<void> clear() async {
    final box = await Hive.openBox<String>(boxName);
    await box.clear();
  }

  // 是否存在
  Future<bool> containsKey(String key) async {
    final box = await Hive.openBox<String>(boxName);
    return box.containsKey(key);
  }
}
