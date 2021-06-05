///解析枚举
T getEnumFromString<T>(Iterable<T> values, String str) {
  return values.firstWhere(
    (T f) => f.toString().split('.').last == str,
  );
}

///解析枚举
String getStringFromEnum<T>(T? t) {
  if (t == null) {
    return '';
  }

  return t.toString().split('.').last;
}

///平台类型
enum JMPlatformType {
  ///安卓
  android,

  ///苹果
  ios,

  ///pc 客户端
  windows,

  ///网页
  web,

  ///所有平台
  all
}

///会话类型
enum JMConversationType {
  ///单聊
  single,

  ///群聊
  group,

  ///聊天室
  chatRoom
}

///目标类型
enum JMTargetType {
  ///用户
  user,

  ///群组
  group
}

/// 'male' | 'female' | 'unknown';
enum JMGender {
  ///男
  male,

  ///女
  female,

  ///未知
  unknown
}

///群组类型
enum JMGroupType {
  ///私有群组
  private,

  ///公开
  public
}

///登陆状态
enum JMLoginStateChangedType {
  /// 被踢、被迫退出
  user_logout,

  /// 用户被删除
  user_deleted,

  /// 非客户端修改密码
  user_password_change,

  /// 用户登录状态异常
  user_login_status_unexpected,

  ///用户被禁用
  user_disabled
}

///联系人通知类型
enum JMContactNotifyType {
  ///收到邀请
  invite_received,

  ///同意邀请
  invite_accepted,

  ///邀请被拒绝
  invite_declined,

  ///联系人已删除
  contact_deleted
}

///事件类型
enum JMEventCallbackType {
  ///
  none,

  ///
  receiveMessage,

  ///
  syncOfflineMessage,

  ///
  loginStateChangedType,

  ///
  contactNotify,

  ///
  clickMessageNotification,

  ///
  syncRoamingMessage,

  ///
  receiveTransCommand,

  ///
  receiveChatRoomMessage,

  ///
  receiveApplyJoinGroupApproval,

  ///
  receiveGroupAdminReject,

  ///
  receiveGroupAdminApproval,

  ///
  retractMessage,
}

///群成员类型
enum JMGroupMemberType {
  /// 群主
  owner,

  /// 管理员
  admin,

  /// 普通成员
  ordinary
}
