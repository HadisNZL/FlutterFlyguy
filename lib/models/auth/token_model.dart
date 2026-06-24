import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'token_model.freezed.dart';
part 'token_model.g.dart';

@freezed
class TokenModel with _$TokenModel {
  @HiveType(typeId: 0, adapterName: 'TokenModelAdapter')
  const factory TokenModel({
    @HiveField(0) required String accessToken,
    @HiveField(1) required int expiresIn,
    @HiveField(2) required String tokenType,
    @HiveField(3) required String refreshToken,
    @HiveField(4) required int loginTime,
  }) = _TokenModel;

  const TokenModel._();

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);

  /// 计算过期时间戳（毫秒）
  int get expireTime => loginTime + (expiresIn * 1000);

  /// 是否需要刷新（距离过期不足24小时）
  bool get needsRefresh {
    final remainingTime = expireTime - DateTime.now().millisecondsSinceEpoch;
    return remainingTime < 86400000; // 24小时 = 86400000毫秒
  }

  /// 是否已过期
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch >= expireTime;
  }
}
