///发送消息时的通知设置
class JMMessageSendOptions {
  ///解析json
  JMMessageSendOptions.fromJson(Map<dynamic, dynamic> json)
      : isShowNotification = json['isShowNotification'] as bool,
        isRetainOffline = json['isRetainOffline'] as bool,
        isCustomNotificationEnabled =
            json['isCustomNotificationEnabled'] as bool,
        notificationTitle = json['notificationTitle'].toString(),
        notificationText = json['notificationText'].toString(),
        needReadReceipt = json['needReadReceipt'] as bool;

  /// 接收方是否针对此次消息发送展示通知栏通知。
  final bool isShowNotification;

  ///  是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。
  final bool isRetainOffline;

  ///是否开启自定义通知
  final bool isCustomNotificationEnabled;

  /// 设置此条消息在��收方通知栏所展示通知的标题。
  final String notificationTitle;

  /// 设置此条消息在接收方通��栏所展示通知的内容。
  final String notificationText;

  /// ��置这条消息的发送是否需要对方发送已读回执，false，默认值
  final bool needReadReceipt;

  ///转为json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isShowNotification': isShowNotification,
      'isRetainOffline': isRetainOffline,
      'isCustomNotificationEnabled': isCustomNotificationEnabled,
      'notificationTitle': notificationTitle,
      'notificationText': notificationText,
      'needReadReceipt': needReadReceipt,
    };
  }
}

///消息通知设置
class JMMessageOptions {
  ///拓展参数
  final Map<dynamic, dynamic> extras;

  ///通知设置
  final JMMessageSendOptions messageSendingOptions;

  ///构造
  JMMessageOptions(this.extras, this.messageSendingOptions);

  ///转为json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'extras': extras,
      'messageSendingOptions': messageSendingOptions.toJson()
    };
  }
}

/// iOS 通知设置项
class JMNotificationSettingsIOS {
  ///
  final bool sound;

  ///
  final bool alert;

  ///
  final bool badge;

  ///
  const JMNotificationSettingsIOS({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  ///
  Map<String, dynamic> toMap() {
    return <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
  }
}
