import 'package:jmessage_flutter/src/bean/message.dart';

import 'conversation_info.dart';

///同步离线消息
class SyncOfflineMessage {
  ///会话信息
  final JMConversationInfo conversation;

  ///离线消息
  final List<JMNormalMessage> messages;

  ///
  SyncOfflineMessage(this.conversation, this.messages);
}
