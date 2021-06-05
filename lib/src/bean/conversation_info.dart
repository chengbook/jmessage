import 'package:jmessage_flutter/src/bean/conversation_type.dart';
import 'package:jmessage_flutter/src/enum/jmessage_enum.dart';
import 'package:jmessage_flutter/src/jmessage.dart';

import 'jm_info.dart';
import 'message.dart';
import 'send_options.dart';

///会话信息
class JMConversationInfo {
  /// 会话类型
  final JMConversationType conversationType;

  /// 会话标题
  final String title;

  /// 未读消息数
  final int unreadCount;

  /// JMUserInfo or JMGroupInfo or JMChatRoom
  late final BaseInfo target;

  /// 最近的一条消息对象。如果不存在消息，则 conversation 对象中没有该属性。
  late final JMNormalMessage? latestMessage;

  ///拓展参数
  final Map<dynamic, dynamic> extras;

  ///
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'conversationType': getStringFromEnum(conversationType),
      'unreadCount': unreadCount,
      'extras': extras.toString(),
    };
  }

  ///
  JMConversationInfo.fromJson(Map<dynamic, dynamic> json)
      : conversationType = getEnumFromString(
            JMConversationType.values, json['conversationType'].toString()),
        title = json['title'].toString(),
        unreadCount = json['unreadCount'] as int,
        extras = json['extras'] as Map<String, dynamic> {
    switch (conversationType) {
      case JMConversationType.single:
        target = JMUserInfo.fromJson(json['target'] as Map<String, dynamic>);
        break;
      case JMConversationType.group:
        target = JMGroupInfo.fromJson(json['target'] as Map<String, dynamic>);
        break;
      case JMConversationType.chatRoom:
        target =
            JMChatRoomInfo.fromJson(json['target'] as Map<String, dynamic>);
        break;
    }

    final Object? map = json['latestMessage'];
    if (map == null) {
      latestMessage = null;
    } else {
      latestMessage = JMNormalMessage.cast(map as Map<String, dynamic>);
    }
  }

  ///是否为我的消息
  bool isMyMessage(JMNormalMessage message) {
    return target == message.target;
  }

  ///设置拓展方法
  Future<JMConversationInfo> setExtras(Map<String, dynamic> extras) async {
    this.extras.addAll(extras);
    return await jMessage.setConversationExtras(
      type: target.targetType,
      extras: extras,
    );
  }

  ///发送文字消息
  Future<JMTextMessage> sendTextMessage({
    required String text,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final JMTextMessage msg = await jMessage.sendTextMessage(
        type: target.targetType,
        text: text,
        sendOption: sendOption,
        extras: extras);
    return msg;
  }

  /// sendImage
  Future<JMImageMessage> sendImageMessage({
    required String path,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final JMImageMessage msg = await jMessage.sendImageMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  /// sendVoice
  Future<JMVoiceMessage> sendVoiceMessage({
    required String path,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final JMVoiceMessage msg = await jMessage.sendVoiceMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  /// sendCustom
  Future<JMCustomMessage> sendCustomMessage({
    required Map<dynamic, dynamic> customObject,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final JMCustomMessage msg = await jMessage.sendCustomMessage(
      type: target.targetType,
      customObject: customObject,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  /// sendLocation
  Future<JMLocationMessage> sendLocationMessage({
    required double latitude,
    required double longitude,
    required int scale,
    String? address,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final JMLocationMessage msg = await jMessage.sendLocationMessage(
      type: target.targetType,
      latitude: latitude,
      longitude: longitude,
      scale: scale,
      address: address,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  /// sendFile
  Future<JMFileMessage> sendFileMessage({
    required ConversationType type,
    required String path,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final JMFileMessage msg = await jMessage.sendFileMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  /// getHistoryMessages
  Future<List<JMNormalMessage>> getHistoryMessages(
      {required int from, required int limit, bool isDescend = false}) async {
    final List<JMNormalMessage> msgs = await jMessage.getHistoryMessages(
        type: target.targetType,
        from: from,
        limit: limit,
        isDescend: isDescend);
    return msgs;
  }
}
