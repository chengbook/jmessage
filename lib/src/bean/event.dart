import 'package:jmessage_flutter/src/enum/jmessage_enum.dart';

import 'jm_info.dart';

///联系人通知事件
class JMContactNotifyEvent {
  ///联系人类型
  final JMContactNotifyType type;

  ///原因
  final String reason;

  ///来源用户
  final String fromUserName;

  ///来源用户所属app
  final String fromUserAppKey;

  ///转为Map
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': getStringFromEnum(type),
      'reason': reason,
      'fromUserName': fromUserName,
      'fromUserAppKey': fromUserAppKey
    };
  }

  ///解析json
  JMContactNotifyEvent.fromJson(Map<dynamic, dynamic> json)
      : type = getEnumFromString(
            JMContactNotifyType.values, json['type'].toString()),
        reason = json['reason'].toString(),
        fromUserName = json['fromUsername'].toString(),
        fromUserAppKey = json['fromUserAppKey'].toString();
}

///透传命令事件
class JMReceiveTransCommandEvent {
  ///消息
  final String message;

  ///发送者
  final JMUserInfo sender;

  ///接收者
  late final BaseInfo receiver; // JMUserInfo | JMGroupInfo;
  ///接收者类型
  final JMTargetType receiverType; // user | group // DIFFerent
  ///
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'receiverType': getStringFromEnum(receiverType)
    };
  }

  ///
  JMReceiveTransCommandEvent.fromJson(Map<dynamic, dynamic> json)
      : receiverType = getEnumFromString(
            JMTargetType.values, json['receiverType'].toString()),
        message = json['message'].toString(),
        sender = JMUserInfo.fromJson(json['sender'] as Map<String, dynamic>) {
    switch (receiverType) {
      case JMTargetType.user:
        receiver =
            JMUserInfo.fromJson(json['receiver'] as Map<String, dynamic>);
        break;
      case JMTargetType.group:
        receiver =
            JMGroupInfo.fromJson(json['receiver'] as Map<String, dynamic>);
        break;
    }
  }
}

///群组事件
class JMReceiveApplyJoinGroupApprovalEvent {
  ///事件id
  final String eventId;

  ///群组id
  final String groupId;

  ///是否为邀请
  final bool isInitiativeApply;

  ///发送者
  final JMUserInfo sendApplyUser;

  ///加入群组人的列表
  late final List<JMUserInfo> joinGroupUsers;

  ///原因
  final String reason;

  ///
  JMReceiveApplyJoinGroupApprovalEvent.fromJson(Map<dynamic, dynamic> json)
      : eventId = json['eventId'].toString(),
        groupId = json['groupId'].toString(),
        isInitiativeApply = json['isInitiativeApply'] as bool,
        sendApplyUser =
            JMUserInfo.fromJson(json['sendApplyUser'] as Map<String, dynamic>),
        reason = json['reason'].toString() {
    final List<dynamic> userJsons = json['joinGroupUsers'] as List<dynamic>;
    joinGroupUsers = userJsons.map((dynamic userJson) {
      return JMUserInfo.fromJson(userJson as Map<String, dynamic>);
    }).toList();
  }
}

///管理员拒绝加入事件
class JMReceiveGroupAdminRejectEvent {
  ///群组id
  final String groupId;

  ///拒绝的管理员
  final JMUserInfo groupManager;

  ///拒绝原因
  final String reason;

  ///
  JMReceiveGroupAdminRejectEvent.fromJson(Map<dynamic, dynamic> json)
      : groupId = json['groupId'].toString(),
        groupManager =
            JMUserInfo.fromJson(json['groupManager'] as Map<String, dynamic>),
        reason = json['reason'].toString();
}

///管理员同意加入事件
class JMReceiveGroupAdminApprovalEvent {
  ///是否同意
  final bool isAgree;

  ///事件id
  final String applyEventId;

  ///群组id
  final String groupId;

  ///同意的管理员信息
  final JMUserInfo groupAdmin;

  ///同意的用户列表
  late final List<JMUserInfo> users;

  ///
  JMReceiveGroupAdminApprovalEvent.fromJson(Map<dynamic, dynamic> json)
      : isAgree = json['isAgree'] as bool,
        applyEventId = json['applyEventId'].toString(),
        groupId = json['groupId'].toString(),
        groupAdmin =
            JMUserInfo.fromJson(json['groupAdmin'] as Map<String, dynamic>) {
    final List<dynamic> userJsons = json['users'] as List<dynamic>;
    users = userJsons.map((dynamic userJson) {
      return JMUserInfo.fromJson(userJson as Map<String, dynamic>);
    }).toList();
  }
}
