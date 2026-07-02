import 'package:freezed_annotation/freezed_annotation.dart';

part 'pic_info_model.freezed.dart';
part 'pic_info_model.g.dart';

@freezed
class PicInfoModel with _$PicInfoModel {
  const factory PicInfoModel({
    @JsonKey(name: 'NotificationId') int? notificationId,
    @JsonKey(name: 'NotificationSeq') int? notificationSeq,
    @JsonKey(name: 'PicId') int? picId,
    @JsonKey(name: 'RelatedNotificationId') int? relatedNotificationId,
    @JsonKey(name: 'DeviceId') int? deviceId,
    @JsonKey(name: 'PicName') String? picName,
    @JsonKey(name: 'CreateDate') String? createDate,
    @JsonKey(name: 'IsEncryption') int? isEncryption,
    @JsonKey(name: 'IsVideo') int? isVideo,
    @JsonKey(name: 'PicType') String? picType,
    @JsonKey(name: 'PicNameType') String? picNameType,
    @JsonKey(name: 'PicCreateDate') String? picCreateDate,
    @JsonKey(name: 'IsSupportZoom') int? isSupportZoom,
  }) = _PicInfoModel;

  factory PicInfoModel.fromJson(Map<String, dynamic> json) =>
      _$PicInfoModelFromJson(json);
}
