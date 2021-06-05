import 'package:jmessage_flutter/src/enum/jmessage_enum.dart';

import 'jm_info.dart';

///群成员信息
class JMGroupMemberInfo {
  ///用户信息
  final JMUserInfo user;

  ///群昵称
  final String groupNickname;

  ///群成员类型
  final JMGroupMemberType memberType;

  ///加入群的时间
  final int joinGroupTime;

  ///
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user': user.toJson(),
      'groupNickname': groupNickname,
      'memberType': getStringFromEnum(memberType),
      'joinGroupTime': joinGroupTime
    };
  }

  ///
  JMGroupMemberInfo.fromJson(Map<String, dynamic> json)
      : user = JMUserInfo.fromJson(json['user'] as Map<String, dynamic>),
        groupNickname = json['groupNickname'].toString(),
        memberType = getEnumFromString(
            JMGroupMemberType.values, json['memberType'].toString()),
        joinGroupTime = json['joinGroupTime'] as int;
}
