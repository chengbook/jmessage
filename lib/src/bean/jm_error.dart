///错误
class JMError {
  ///错误码
  final String code;

  ///错误描述
  final String description;

  ///转为json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'description': description,
    };
  }

  ///解析json
  JMError.fromJson(Map<String, dynamic> json)
      : code = json['code'].toString(),
        description = json['description'].toString();
}
