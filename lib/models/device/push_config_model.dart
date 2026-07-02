import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_config_model.freezed.dart';
part 'push_config_model.g.dart';

@freezed
class PushConfigModel with _$PushConfigModel {
  const factory PushConfigModel({
    @JsonKey(name: 'PushCategoryList') List<PushCategoryModel>? pushCategoryList,
    @JsonKey(name: 'Result') PushResultModel? result,
    @JsonKey(name: 'AccountId') int? accountId,
    @JsonKey(name: 'DeviceID') int? deviceId,
    @JsonKey(name: 'IsEnable') bool? isEnable,
  }) = _PushConfigModel;

  factory PushConfigModel.fromJson(Map<String, dynamic> json) =>
      _$PushConfigModelFromJson(json);
}

@freezed
class PushCategoryModel with _$PushCategoryModel {
  const factory PushCategoryModel({
    @JsonKey(name: 'PushCategoryName') String? pushCategoryName,
    @JsonKey(name: 'IsPush') bool? isPush,
    @JsonKey(name: 'PushCategoryId') int? pushCategoryId,
    @JsonKey(name: 'PushSort') int? pushSort,
    @JsonKey(name: 'PushDes') String? pushDes,
    @JsonKey(name: 'Icon') String? icon,
  }) = _PushCategoryModel;

  factory PushCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$PushCategoryModelFromJson(json);
}

@freezed
class PushResultModel with _$PushResultModel {
  const factory PushResultModel({
    @JsonKey(name: 'Code') int? code,
    @JsonKey(name: 'Message') String? message,
  }) = _PushResultModel;

  factory PushResultModel.fromJson(Map<String, dynamic> json) =>
      _$PushResultModelFromJson(json);
}
