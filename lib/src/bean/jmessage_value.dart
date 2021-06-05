import 'package:jmessage_flutter/src/enum/jmessage_enum.dart';

import 'conversation_info.dart';
import 'event.dart';
import 'message.dart';
import 'offline_message.dart';

/// 函数回调
typedef JMCallback = void Function(dynamic a, dynamic b);

/// im返回事件的回调
class JMessageValue {
  ///事件类型
  final JMEventCallbackType type;

  ///接收消息
  final JMNormalMessage? receiveMessage;

  ///同步离线消息
  final SyncOfflineMessage? syncOfflineMessage;

  ///登陆状态
  final JMLoginStateChangedType? loginStateChangedType;

  ///联系人事件通知
  final JMContactNotifyEvent? contactNotify;

  ///点击的消息
  final JMNormalMessage? clickMessageNotification;

  ///同步漫游消息
  final JMConversationInfo? syncRoamingMessage;

  ///透传命令事件
  final JMReceiveTransCommandEvent? receiveTransCommand;

  ///接收聊天室消息
  final List<JMNormalMessage>? receiveChatRoomMessage;

  ///申请加入群组的事件
  final JMReceiveApplyJoinGroupApprovalEvent? receiveApplyJoinGroupApproval;

  ///管理员拒绝加入群组的事件
  final JMReceiveGroupAdminRejectEvent? receiveGroupAdminReject;

  ///管理员同意加入群组的事件
  final JMReceiveGroupAdminApprovalEvent? receiveGroupAdminApproval;

  ///撤回消息
  final JMNormalMessage? retractMessage;

  ///
  JMessageValue(
      {this.receiveMessage,
      this.syncOfflineMessage,
      this.loginStateChangedType,
      this.contactNotify,
      this.clickMessageNotification,
      this.syncRoamingMessage,
      this.receiveTransCommand,
      this.receiveChatRoomMessage,
      this.receiveApplyJoinGroupApproval,
      this.receiveGroupAdminReject,
      this.receiveGroupAdminApproval,
      this.retractMessage,
      this.type = JMEventCallbackType.none});

  ///
  JMessageValue copyWith({
    JMEventCallbackType? type,
    JMNormalMessage? receiveMessage,
    SyncOfflineMessage? syncOfflineMessage,
    JMLoginStateChangedType? loginStateChangedType,
    JMContactNotifyEvent? contactNotify,
    JMNormalMessage? clickMessageNotification,
    JMConversationInfo? syncRoamingMessage,
    JMReceiveTransCommandEvent? receiveTransCommand,
    List<JMNormalMessage>? receiveChatRoomMessage,
    JMReceiveApplyJoinGroupApprovalEvent? receiveApplyJoinGroupApproval,
    JMReceiveGroupAdminRejectEvent? receiveGroupAdminReject,
    JMReceiveGroupAdminApprovalEvent? receiveGroupAdminApproval,
    JMNormalMessage? retractMessage,
  }) {
    return JMessageValue(
      type: type ?? this.type,
      receiveMessage: receiveMessage ?? this.receiveMessage,
      syncOfflineMessage: syncOfflineMessage ?? this.syncOfflineMessage,
      loginStateChangedType:
          loginStateChangedType ?? this.loginStateChangedType,
      contactNotify: contactNotify ?? this.contactNotify,
      clickMessageNotification:
          clickMessageNotification ?? this.clickMessageNotification,
      syncRoamingMessage: syncRoamingMessage ?? this.syncRoamingMessage,
      receiveTransCommand: receiveTransCommand ?? this.receiveTransCommand,
      receiveChatRoomMessage:
          receiveChatRoomMessage ?? this.receiveChatRoomMessage,
      receiveApplyJoinGroupApproval:
          receiveApplyJoinGroupApproval ?? this.receiveApplyJoinGroupApproval,
      receiveGroupAdminReject:
          receiveGroupAdminReject ?? this.receiveGroupAdminReject,
      receiveGroupAdminApproval:
          receiveGroupAdminApproval ?? this.receiveGroupAdminApproval,
      retractMessage: retractMessage ?? this.retractMessage,
    );
  }
}
