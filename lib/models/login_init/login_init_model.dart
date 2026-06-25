import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'defense_area_model.dart';

part 'login_init_model.freezed.dart';
part 'login_init_model.g.dart';

@freezed
class LoginInitModel with _$LoginInitModel {
  @HiveType(typeId: 3, adapterName: 'LoginInitModelAdapter')
  const factory LoginInitModel({
    @HiveField(0) @JsonKey(name: 'APPAccountInfo') required APPAccountInfo accountInfo,
    @HiveField(1) @JsonKey(name: 'SipInfo') required SipInfo sipInfo,
    @HiveField(2) @JsonKey(name: 'DefenseAreaList') required List<DefenseArea> defenseAreaList,
    @HiveField(3) @JsonKey(name: 'AppSystemSetting') required AppSystemSetting systemSetting,
  }) = _LoginInitModel;

  factory LoginInitModel.fromJson(Map<String, dynamic> json) =>
      _$LoginInitModelFromJson(json);
}

@freezed
class APPAccountInfo with _$APPAccountInfo {
  @HiveType(typeId: 4, adapterName: 'APPAccountInfoAdapter')
  const factory APPAccountInfo({
    @HiveField(0) @JsonKey(name: 'Domain') required String domain,
    @HiveField(1) @JsonKey(name: 'AccountId') required int accountId,
    @HiveField(2) @JsonKey(name: 'Email') required String email,
    @HiveField(3) @JsonKey(name: 'NickName') required String nickName,
    @HiveField(4) @JsonKey(name: 'FirstName') required String firstName,
    @HiveField(5) @JsonKey(name: 'LastName') required String lastName,
    @HiveField(6) @JsonKey(name: 'Headimgurl') required String headimgurl,
    @HiveField(7) @JsonKey(name: 'PhoneNumber') required String phoneNumber,
    @HiveField(8) @JsonKey(name: 'PhoneCountryCode') required String phoneCountryCode,
    @HiveField(9) @JsonKey(name: 'LoginName') required String loginName,
    @HiveField(10) @JsonKey(name: 'Market') required String market,
  }) = _APPAccountInfo;

  factory APPAccountInfo.fromJson(Map<String, dynamic> json) =>
      _$APPAccountInfoFromJson(json);
}

@freezed
class SipInfo with _$SipInfo {
  @HiveType(typeId: 5, adapterName: 'SipInfoAdapter')
  const factory SipInfo({
    @HiveField(0) @JsonKey(name: 'SipNumber') required String sipNumber,
    @HiveField(1) @JsonKey(name: 'Pin') required String pin,
    @HiveField(2) @JsonKey(name: 'HostPortList') required String hostPortList,
    @HiveField(3) @JsonKey(name: 'DefaultInvPhone') required String defaultInvPhone,
    @HiveField(4) @JsonKey(name: 'DefaultInvCountryCode') required String defaultInvCountryCode,
  }) = _SipInfo;

  factory SipInfo.fromJson(Map<String, dynamic> json) =>
      _$SipInfoFromJson(json);
}

@freezed
class AppSystemSetting with _$AppSystemSetting {
  @HiveType(typeId: 11, adapterName: 'AppSystemSettingAdapter')
  const factory AppSystemSetting({
    @HiveField(0) @JsonKey(name: 'MessageOrLiveInterval') required int messageOrLiveInterval,
  }) = _AppSystemSetting;

  factory AppSystemSetting.fromJson(Map<String, dynamic> json) =>
      _$AppSystemSettingFromJson(json);
}
