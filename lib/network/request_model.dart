import 'package:json_annotation/json_annotation.dart';

part 'request_model.g.dart';

@JsonSerializable()
class LicenseRequest {
  String license;

  LicenseRequest({
    required this.license,
  });

  factory LicenseRequest.fromJson(Map<String, dynamic> json) => _$LicenseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LicenseRequestToJson(this);
}