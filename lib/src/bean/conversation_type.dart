import 'package:jmessage_flutter/src/enum/jmessage_enum.dart';

///会话类型基类
abstract class ConversationType {
  ///会话类型
  ConversationType(this.type);

  ///会话类型
  final JMConversationType type;

  ///转为json
  Map<String, dynamic> toJson();
}

///群聊
class JMGroup extends ConversationType {
  ///构造，设置会话类型
  JMGroup(this.groupId) : super(JMConversationType.group);

  ///群id
  final String groupId;

  @override
  bool operator ==(dynamic other) {
    return other is JMGroup && other.groupId == groupId;
  }

  ///转为json
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': getStringFromEnum(JMConversationType.group),
      'groupId': groupId
    };
  }
}

///单聊
class JMSingle extends ConversationType {
  ///
  JMSingle({required this.username, required this.appKey})
      : super(JMConversationType.single);

  ///昵称
  final String username;

  ///appKey
  final String appKey;

  /// 转为json
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': getStringFromEnum(JMConversationType.single),
      'username': username,
      'appKey': appKey
    };
  }
}

///聊天室
class JMChatRoom extends ConversationType {
  ///聊天室构造
  JMChatRoom({required this.roomId}) : super(JMConversationType.chatRoom);

  ///聊天室id
  final String roomId;

  @override
  bool operator ==(dynamic other) {
    return other is JMChatRoom && other.roomId == roomId;
  }

  ///转为json
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': getStringFromEnum(JMConversationType.chatRoom),
      'roomId': roomId
    };
  }
}
