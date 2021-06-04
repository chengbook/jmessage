import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jmessage_flutter/src/bean/jmessage.dart';

/// log 的标签
const String flutterLog = '| JMessage | Flutter | ';

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

/// 函数回调
typedef JMCallback = void Function(dynamic a, dynamic b);

/// 点击通知栏

// message 和 retractedMessage 可能是 JMTextMessage | JMVoiceMessage | JMImageMessage | JMFileMessage | JMEventMessage | JMCustomMessage;
typedef JMMessageEventListener = void Function(dynamic message);

///
typedef JMSyncOfflineMessageListener = void Function(
    JMConversationInfo conversation, List<dynamic> messageArray);

///
class SyncOfflineMessage {
  ///
  final JMConversationInfo conversation;

  ///
  final List<dynamic> messages;

  ///
  SyncOfflineMessage(this.conversation, this.messages);
}

///
typedef JMSyncRoamingMessageListener = void Function(
    JMConversationInfo conversation);

///
typedef JMLoginStateChangedListener = void Function(
    JMLoginStateChangedType type);

///
typedef JMContactNotifyListener = void Function(JMContactNotifyEvent event);

///
typedef JMMessageRetractListener = void Function(dynamic retractedMessage);

///
typedef JMReceiveTransCommandListener = void Function(
    JMReceiveTransCommandEvent event);

///
typedef JMReceiveChatRoomMessageListener = void Function(
    List<dynamic> messageList);

///
typedef JMReceiveApplyJoinGroupApprovalListener = void Function(
    JMReceiveApplyJoinGroupApprovalEvent event);

///
typedef JMReceiveGroupAdminRejectListener = void Function(
    JMReceiveGroupAdminRejectEvent event);

///
typedef JMReceiveGroupAdminApprovalListener = void Function(
    JMReceiveGroupAdminApprovalEvent event);

///
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

/// im返回事件的回调
class JMessageValue {
  ///
  final JMEventCallbackType type;

  ///
  final JMNormalMessage? receiveMessage;

  ///
  final SyncOfflineMessage? syncOfflineMessage;

  ///
  final JMLoginStateChangedType? loginStateChangedType;

  ///
  final JMContactNotifyEvent? contactNotify;

  ///
  final Object? clickMessageNotification;

  ///
  final JMConversationInfo? syncRoamingMessage;

  ///
  final JMReceiveTransCommandEvent? receiveTransCommand;

  ///
  final List<dynamic>? receiveChatRoomMessage;

  ///
  final JMReceiveApplyJoinGroupApprovalEvent? receiveApplyJoinGroupApproval;

  ///
  final JMReceiveGroupAdminRejectEvent? receiveGroupAdminReject;

  ///
  final JMReceiveGroupAdminApprovalEvent? receiveGroupAdminApproval;

  ///
  final Object? retractMessage;

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

///
class JmessageFlutter extends ValueNotifier<JMessageValue> {
  final MethodChannel _channel = const MethodChannel('jmessage_flutter');

  ///
  JmessageFlutter() : super(JMessageValue()) {
    _channel.setMethodCallHandler(_handleMethod);
  }

  ///
  // Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }

  Future<void> _handleMethod(MethodCall call) async {
    print('flutter 处理方法命令中 = ${call.method}');
    switch (call.method) {
      case 'onReceiveMessage':
        final JMNormalMessage msg =
            JMNormalMessage.cast(call.arguments as Map<String, dynamic>);
        print('接收到了消息 ===========$msg');
        value = value.copyWith(
            type: JMEventCallbackType.receiveMessage, receiveMessage: msg);

        break;
      case 'onRetractMessage':
        final Map<String, dynamic> params =
            call.arguments as Map<String, dynamic>;

        final JMNormalMessage retractMsg = JMNormalMessage.cast(
            params['retractedMessage'] as Map<String, dynamic>);
        value = value.copyWith(
            type: JMEventCallbackType.retractMessage,
            retractMessage: retractMsg);

        break;
      case 'onLoginStateChanged':
        final String type =
            (call.arguments as Map<String, dynamic>)['type'].toString();
        final JMLoginStateChangedType loginState =
            getEnumFromString(JMLoginStateChangedType.values, type);
        value = value.copyWith(
            type: JMEventCallbackType.loginStateChangedType,
            loginStateChangedType: loginState);

        break;
      case 'onSyncOfflineMessage':
        final Map<String, dynamic> param =
            call.arguments as Map<String, dynamic>;
        final List<dynamic> messages = (param['messageArray'] as List<dynamic>)
            .map((dynamic e) => e as Map<String, dynamic>)
            .map<dynamic>((Map<String, dynamic> e) => JMNormalMessage.cast(e))
            .toList();

        final SyncOfflineMessage syncOfflineMsg = SyncOfflineMessage(
            JMConversationInfo.fromJson(
                param['conversation'] as Map<String, dynamic>),
            messages);

        value = value.copyWith(
            type: JMEventCallbackType.syncOfflineMessage,
            syncOfflineMessage: syncOfflineMsg);

        break;
      case 'onSyncRoamingMessage':
        final Map<String, dynamic> json =
            call.arguments as Map<String, dynamic>;
        final JMConversationInfo conversationInfo =
            JMConversationInfo.fromJson(json);
        value = value.copyWith(
            syncRoamingMessage: conversationInfo,
            type: JMEventCallbackType.syncRoamingMessage);
        break;
      case 'onContactNotify':
        final Map<String, dynamic> json =
            call.arguments as Map<String, dynamic>;
        final JMContactNotifyEvent contactNotify =
            JMContactNotifyEvent.fromJson(json);
        value = value.copyWith(
            contactNotify: contactNotify,
            type: JMEventCallbackType.contactNotify);

        break;
      case 'onClickMessageNotification':
        // TODO: only work in android
        final Map<String, dynamic> json =
            call.arguments as Map<String, dynamic>;
        print('点击了消息通知========================= $json');
        final JMNormalMessage msg = JMNormalMessage.cast(json);

        value = value.copyWith(
            clickMessageNotification: msg,
            type: JMEventCallbackType.clickMessageNotification);

        break;
      case 'onReceiveTransCommand':
        final Map<String, dynamic> json =
            call.arguments as Map<String, dynamic>;
        final JMReceiveTransCommandEvent ev =
            JMReceiveTransCommandEvent.fromJson(json);
        value = value.copyWith(
            receiveTransCommand: ev,
            type: JMEventCallbackType.receiveTransCommand);
        break;
      case 'onReceiveChatRoomMessage':
        final List<JMNormalMessage> messages = (call.arguments as List<dynamic>)
            .map((dynamic e) => e as Map<String, dynamic>)
            .map((Map<String, dynamic> e) => JMNormalMessage.cast(e))
            .toList();
        value = value.copyWith(
            receiveChatRoomMessage: messages,
            type: JMEventCallbackType.receiveChatRoomMessage);
        break;
      case 'onReceiveApplyJoinGroupApproval':
        final Map<String, dynamic> json =
            call.arguments as Map<String, dynamic>;
        final JMReceiveApplyJoinGroupApprovalEvent e =
            JMReceiveApplyJoinGroupApprovalEvent.fromJson(json);
        value = value.copyWith(
            receiveApplyJoinGroupApproval: e,
            type: JMEventCallbackType.receiveApplyJoinGroupApproval);
        break;
      case 'onReceiveGroupAdminReject':
        final Map<String, dynamic> json =
            call.arguments as Map<String, dynamic>;
        final JMReceiveGroupAdminRejectEvent e =
            JMReceiveGroupAdminRejectEvent.fromJson(json);

        value = value.copyWith(
            receiveGroupAdminReject: e,
            type: JMEventCallbackType.receiveGroupAdminReject);
        break;
      case 'onReceiveGroupAdminApproval':
        final Map<String, dynamic> json =
            call.arguments as Map<String, dynamic>;
        final JMReceiveGroupAdminApprovalEvent e =
            JMReceiveGroupAdminApprovalEvent.fromJson(json);
        value = value.copyWith(
            receiveGroupAdminApproval: e,
            type: JMEventCallbackType.receiveGroupAdminApproval);
        break;
      default:
        throw UnsupportedError('Unrecognized Event');
    }
    return;
  }

  ///初始化
  Future<void> init({
    required bool isOpenMessageRoaming,
    required String appKey,
    String? channel,
    bool isProduction = false,
  }) async {
    return _channel.invokeMethod<void>('setup', <String, dynamic>{
      'isOpenMessageRoaming': isOpenMessageRoaming,
      'appkey': appKey,
      'channel': channel,
      'isProduction': isProduction
    });
  }

  ///设置debug模式
  Future<void> setDebugMode({bool enable = false}) async {
    return _channel
        .invokeMethod('setDebugMode', <String, bool>{'enable': enable});
  }

  ///
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  ///
  Future<void> applyPushAuthority(
      [JMNotificationSettingsIOS iosSettings =
          const JMNotificationSettingsIOS()]) async {
    if (!Platform.isIOS) {
      return;
    }
    return _channel.invokeMethod<void>(
        'applyPushAuthority', iosSettings.toMap());
  }

  ///
  /// iOS Only
  /// 设置应用 Badge（小红点）
  ///
  /// @param {Int} badge
  ///
  Future<void> setBadge({required int badge}) async {
    return _channel
        .invokeMethod<void>('setBadge', <String, int>{'badge': badge});
  }

  ///用户注册
  Future<void> userRegister(
      {required String username,
      required String password,
      String? nickname}) async {
    print('Action - userRegister: username=$username,pw=$password');
    return _channel.invokeMethod<void>('userRegister', <String, dynamic>{
      'username': username,
      'password': password,
      'nickname': nickname
    });
  }

  ///登录
  /// [JMUserInfo] 用户信息，可能为 null
  Future<JMUserInfo?> login({
    required String username,
    required String password,
  }) async {
    print('Action - login: username=$username,pw=$password');

    final Map<String, dynamic>? userJson = await _channel
        .invokeMapMethod<String, dynamic>('login',
            <String, dynamic>{'username': username, 'password': password});
    if (userJson == null) {
      return null;
    } else {
      return JMUserInfo.fromJson(userJson);
    }
  }

  ///登出
  Future<void> logout() async {
    return await _channel.invokeMethod('logout');
  }

  ///获取我的信息
  Future<JMUserInfo?> getMyInfo() async {
    final Map<String, dynamic>? userJson =
        await _channel.invokeMapMethod<String, dynamic>('getMyInfo');
    if (userJson == null) {
      return null;
    } else {
      return JMUserInfo.fromJson(userJson);
    }
  }

  ///获取用户信息
  Future<JMUserInfo?> getUserInfo(
      {required String username, String? appKey}) async {
    final Map<String, dynamic>? userJson = await _channel
        .invokeMapMethod<String, dynamic>('getUserInfo',
            <String, dynamic>{'username': username, 'appKey': appKey});
    if (userJson == null) {
      return null;
    }
    return JMUserInfo.fromJson(userJson);
  }

  ///修改密码
  Future<void> updateMyPassword(
      {required String oldPwd, required String newPwd}) async {
    return await _channel.invokeMethod('updateMyPassword',
        <String, dynamic>{'oldPwd': oldPwd, 'newPwd': newPwd});
  }

  ///更新头像
  Future<void> updateMyAvatar({required String imgPath}) async {
    return await _channel
        .invokeMethod('updateMyAvatar', <String, dynamic>{'imgPath': imgPath});
  }

  ///更新我的信息
  Future<void> updateMyInfo(
      {int? birthday,
      String? nickname,
      String? signature,
      String? region,
      String? address,
      JMGender? gender,
      Map<String, dynamic>? extras}) async {
    return await _channel.invokeMethod('updateMyInfo', <String, dynamic>{
      'birthday': birthday,
      'nickname': nickname,
      'signature': signature,
      'region': region,
      'address': address,
      'gender': getStringFromEnum(gender),
      'extras': extras,
    });
  }

  ///更新群头像
  Future<void> updateGroupAvatar(
      {required String id, required String imgPath}) async {
    return await _channel.invokeMethod('updateGroupAvatar', <String, dynamic>{
      'id': id,
      'imgPath': imgPath,
    });
  }

  ///下载群头像缩略图
  Future<Map<String, dynamic>?> downloadThumbGroupAvatar({
    required String id,
  }) async {
    final Map<String, dynamic>? res = await _channel
        .invokeMapMethod<String, dynamic>(
            'downloadThumbGroupAvatar', <String, dynamic>{
      'id': id,
    });
    return res;
  }

  ///下载群头像原始图片
  Future<Map<String, dynamic>> downloadOriginalGroupAvatar({
    required String id,
  }) async {
    final Map<String, dynamic>? res = await _channel
        .invokeMapMethod<String, dynamic>(
            'downloadOriginalGroupAvatar', <String, dynamic>{
      'id': id,
    });
    return <String, dynamic>{
      'id': res!['id'] ?? '',
      'filePath': res['filePath'] ?? ''
    };
  }

  ///设置会话的拓展参数
  Future<JMConversationInfo> setConversationExtras(
      {

      /// (JMSingle | JMGroup | JMChatRoom)
      required dynamic type,
      Map<dynamic, dynamic>? extras}) async {
    final Map<String, dynamic> param = <String, dynamic>{};
    if (type is JMSingle) {
      param.addAll(type.toJson());
    } else if (type is JMGroup) {
      param.addAll(type.toJson());
    } else if (type is JMChatRoom) {
      param.addAll(type.toJson());
    }
    param['extras'] = extras;
    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('setConversationExtras', param);
    final JMConversationInfo res = JMConversationInfo.fromJson(resMap!);
    return res; // {id: string; filePath: string}
  }

  ///创建消息
  Future<dynamic> createMessage({
    /// 消息类型
    required JMMessageType type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required dynamic targetType,
    String? text,
    String? path,
    String? fileName,
    Map<String, dynamic>? customObject,
    double? latitude,
    double? longitude,
    int? scale,
    String? address,
    Map<String, dynamic>? extras,
  }) async {
    final Map<String, dynamic> param = <String, dynamic>{};
    if (targetType is JMSingle) {
      param.addAll(targetType.toJson());
    } else if (targetType is JMGroup) {
      param.addAll(targetType.toJson());
    } else if (targetType is JMChatRoom) {
      param.addAll(targetType.toJson());
    }

    if (extras != null) {
      param.addAll(<String, dynamic>{'extras': extras});
    }

    param.addAll(<String, dynamic>{
      'messageType': getStringFromEnum(type),
      'text': text,
      'path': path,
      'fileName': fileName,
      'customObject': customObject,
      'latitude': latitude,
      'longitude': longitude,
      'scale': scale,
      'address': address,
    });

    final Map<String, dynamic>? resMap =
        await _channel.invokeMapMethod<String, dynamic>('createMessage',
            param..removeWhere((String key, dynamic value) => value == null));
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res;
  }

  ///消息参数 [type]: (JMSingle | JMGroup | JMChatRoom)
  Map<String, dynamic> _messageParams(
      {required dynamic type,
      required JMMessageSendOptions? sendOption,
      required Map<String, dynamic>? extras}) {
    final Map<String, dynamic> param = <String, dynamic>{};
    if (type is JMSingle) {
      param.addAll(type.toJson());
    } else if (type is JMGroup) {
      param.addAll(type.toJson());
    } else if (type is JMChatRoom) {
      param.addAll(type.toJson());
    }

    if (sendOption != null) {
      param['messageSendingOptions'] = sendOption.toJson();
    }

    if (extras != null) {
      param['extras'] = extras;
    }
    return param;
  }

  /// message 可能是 JMTextMessage | JMVoiceMessage | JMImageMessage | JMFileMessage | JMCustomMessage;
  /// NOTE: 不要传接收到的消息进去，只能传通过 createMessage 创建的消息。
  Future<dynamic> sendMessage(
      {required JMNormalMessage message,
      JMMessageSendOptions? sendOption}) async {
    final Map<String, dynamic> param = <String, dynamic>{};
    final dynamic targetType = message.target.targetType;
    if (targetType is JMSingle) {
      param.addAll(targetType.toJson());
    } else if (targetType is JMGroup) {
      param.addAll(targetType.toJson());
    } else if (targetType is JMChatRoom) {
      param.addAll(targetType.toJson());
    }

    if (sendOption != null) {
      param['messageSendingOptions'] = sendOption.toJson();
    }

    param['id'] = message.id;
    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('sendDraftMessage', param);
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res;
  }

  ///发送文字消息
  Future<JMTextMessage> sendTextMessage({
    /// (JMSingle | JMGroup | JMChatRoom)
    required dynamic type,
    required String text,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final Map<String, dynamic> param = _messageParams(
      type: type,
      sendOption: sendOption,
      extras: extras,
    );

    param['text'] = text;

    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('sendTextMessage', param);
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res as JMTextMessage;
  }

  ///发送图片消息
  Future<JMImageMessage> sendImageMessage({
    /// (JMSingle | JMGroup | JMChatRoom)
    required dynamic type,
    required String path,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final Map<String, dynamic> param = _messageParams(
      type: type,
      sendOption: sendOption,
      extras: extras,
    );
    param['path'] = path;

    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('sendImageMessage', param);
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res as JMImageMessage;
  }

  ///语音消息
  Future<JMVoiceMessage> sendVoiceMessage({
    /// (JMSingle | JMGroup | JMChatRoom)
    required dynamic type,
    required String path,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final Map<String, dynamic> param = _messageParams(
      type: type,
      sendOption: sendOption,
      extras: extras,
    );
    param['path'] = path;

    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('sendVoiceMessage', param);
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res as JMVoiceMessage;
  }

  ///自定义消息
  Future<JMCustomMessage> sendCustomMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required Map<dynamic, dynamic> customObject,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final Map<String, dynamic> param = _messageParams(
      type: type,
      sendOption: sendOption,
      extras: extras,
    );

    param['customObject'] = customObject;

    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('sendCustomMessage', param);
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res as JMCustomMessage;
  }

  ///发送位置消息
  Future<JMLocationMessage> sendLocationMessage({
    required dynamic type,
    required double latitude,
    required double longitude,
    required int scale,
    String? address,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final Map<String, dynamic> param = _messageParams(
      type: type,
      sendOption: sendOption,
      extras: extras,
    );

    param['latitude'] = latitude;
    param['longitude'] = longitude;
    param['scale'] = scale;
    param['address'] = address;

    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('sendLocationMessage', param);
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res as JMLocationMessage;
  }

  ///发送文件消息
  Future<JMFileMessage> sendFileMessage({
    required dynamic type,
    required String path,
    JMMessageSendOptions? sendOption,
    Map<String, dynamic>? extras,
  }) async {
    final Map<String, dynamic> param = _messageParams(
      type: type,
      sendOption: sendOption,
      extras: extras,
    );
    param['path'] = path;

    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('sendFileMessage', param);
    final JMNormalMessage res = JMNormalMessage.cast(resMap!);
    return res as JMFileMessage;
  }

  /// 消息撤回
  ///
  /// @param target    聊天对象， JMSingle | JMGroup
  /// @param serverMessageId 消息服务器 id
  ///
  ///
  Future<void> retractMessage({
    required dynamic target,

    /// (JMSingle | JMGroup )
    required String serverMessageId,
  }) async {
    Map<String, dynamic> param = <String, dynamic>{};
    if (target is JMSingle) {
      param = target.toJson();
    } else if (target is JMGroup) {
      param = target.toJson();
    }
    param['messageId'] = serverMessageId;

    print('retractMessage: ${param.toString()}');

    return await _channel.invokeMethod('retractMessage', param);
  }

  /// 批量获取本地历史消息
  ///
  /// @param target 聊天对象， JMSingle | JMGroup
  /// @param from  起始位置
  /// @param limit 获取数量
  /// @param isDescend 是否倒叙
  ///
  /// */
  Future<List<JMNormalMessage>> getHistoryMessages(
      {@required dynamic type,

      /// (JMSingle | JMGroup)
      required int from,
      required int limit,
      bool isDescend = false}) async {
    Map<String, dynamic> param = <String, dynamic>{};
    if (type is JMSingle) {
      param = type.toJson();
    } else if (type is JMGroup) {
      param = type.toJson();
    }
    param['from'] = from;
    param['limit'] = limit;
    param['isDescend'] = isDescend;

    final List<Map<String, dynamic>>? resArr =
        await _channel.invokeListMethod('getHistoryMessages', param);

    return resArr!
        .map((Map<String, dynamic> e) => JMNormalMessage.cast(e))
        .toList();
  }

  /// 获取本地单条消息
  ///
  /// @param target    聊天对象， JMSingle | JMGroup
  /// @param messageId 本地数据库中的消息id，非 serverMessageId
  Future<JMNormalMessage> getMessageById({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String messageId,
  }) async {
    Map<String, dynamic> param = <String, dynamic>{};
    if (type is JMSingle) {
      param = type.toJson();
    } else if (type is JMGroup) {
      param = type.toJson();
    }

    param['messageId'] = messageId;

    final Map<String, dynamic>? msgMap = await _channel
        .invokeMapMethod<String, dynamic>('getMessageById', param);

    return JMNormalMessage.cast(msgMap!);
  }

  /// 删除本地单条消息
  ///
  /// @param target    聊天对象， JMSingle | JMGroup
  /// @param messageId 本地数据库中的消息id，非serverMessageId
  ///
  /// */
  Future<void> deleteMessageById({
    required dynamic type,
    required String messageId,
  }) async {
    Map<String, dynamic> param = <String, dynamic>{};
    if (type is JMSingle) {
      param = type.toJson();
    } else if (type is JMGroup) {
      param = type.toJson();
    }
    param['messageId'] = messageId;

    return await _channel.invokeMethod('deleteMessageById', param);
  }

  ///发送邀请
  Future<void> sendInvitationRequest({
    required String username,
    required String reason,
    String? appKey,
  }) async {
    return await _channel
        .invokeMethod('sendInvitationRequest', <String, dynamic>{
      'username': username,
      'reason': reason,
      'appKey': appKey,
    });
  }

  ///同意邀请
  Future<void> acceptInvitation({
    required String username,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('acceptInvitation', <String, dynamic>{
      'username': username,
      'appKey': appKey,
    });
  }

  ///拒绝邀请
  Future<void> declineInvitation({
    required String username,
    required String reason,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('declineInvitation', <String, dynamic>{
      'username': username,
      'reason': reason,
      'appKey': appKey,
    });
  }

  ///从好友列表中移除
  Future<void> removeFromFriendList({
    required String username,
    String? appKey,
  }) async {
    return await _channel
        .invokeMethod('removeFromFriendList', <String, dynamic>{
      'username': username,
      'appKey': appKey,
    });
  }

  ///修改好友备注名称
  Future<void> updateFriendNoteName({
    required String username,
    required String noteName,
    String? appKey,
  }) async {
    return await _channel
        .invokeMethod('updateFriendNoteName', <String, dynamic>{
      'username': username,
      'noteName': noteName,
      'appKey': appKey,
    });
  }

  ///
  Future<void> updateFriendNoteText({
    required String username,
    required String noteText,
    String? appKey,
  }) async {
    return await _channel
        .invokeMethod('updateFriendNoteText', <String, dynamic>{
      'username': username,
      'noteText': noteText,
      'appKey': appKey,
    });
  }

  ///获取好友列表
  Future<List<JMUserInfo>> getFriends() async {
    final List<Map<String, dynamic>>? userJsons =
        await _channel.invokeListMethod('getFriends');

    final List<JMUserInfo> users = userJsons!
        .map((Map<String, dynamic> userMap) => JMUserInfo.fromJson(userMap))
        .toList();
    return users;
  }

  ///创建群组
  Future<String> createGroup({
    JMGroupType groupType = JMGroupType.private,
    required String name,
    String? desc,
  }) async {
    final Object? groupId = await _channel.invokeMethod(
        'createGroup', <String, dynamic>{
      'groupType': getStringFromEnum(groupType),
      'name': name,
      'desc': desc
    });
    return groupId!.toString();
  }

  ///获取群组id
  Future<List<String>> getGroupIds() async {
    final List<String>? groupIds =
        await _channel.invokeListMethod<String>('getGroupIds');

    return groupIds!;
  }

  ///获取群组信息
  Future<JMGroupInfo> getGroupInfo({required String id}) async {
    final Map<String, dynamic>? groupJson = await _channel
        .invokeMapMethod<String, dynamic>(
            'getGroupInfo', <String, dynamic>{'id': id});

    return JMGroupInfo.fromJson(groupJson!);
  }

  ///修改群组信息
  Future<void> updateGroupInfo({
    required String id,
    required String newName,
    String? newDesc,
  }) async {
    return await _channel.invokeMethod('updateGroupInfo',
        <String, dynamic>{'id': id, 'newName': newName, 'newDesc': newDesc});
  }

  ///添加群组成员
  Future<void> addGroupMembers({
    required String id,
    required List<String> usernameArray,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('addGroupMembers', <String, dynamic>{
      'id': id,
      'usernameArray': usernameArray,
      'appKey': appKey,
    });
  }

  ///移除群组成员
  Future<void> removeGroupMembers({
    required String id,
    required List<String> usernames,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('removeGroupMembers', <String, dynamic>{
      'id': id,
      'usernameArray': usernames,
      'appKey': appKey,
    });
  }

  ///退出群组
  Future<void> exitGroup({required String id}) async {
    return await _channel
        .invokeMethod('exitGroup', <String, dynamic>{'id': id});
  }

  ///获取群成员列表
  Future<List<JMGroupMemberInfo>> getGroupMembers({required String id}) async {
    List<Map<String, dynamic>>? membersJsons = await _channel
        .invokeMethod('getGroupMembers', <String, dynamic>{'id': id});

    List<JMGroupMemberInfo> res = membersJsons
        .map((memberJson) => JMGroupMemberInfo.fromJson(memberJson))
        .toList();
    return res;
  }

  Future<void> addUsersToBlacklist(
      {@required List<String> usernameArray, String appKey}) async {
    await _channel.invokeMethod(
        'addUsersToBlacklist',
        {'usernameArray': usernameArray, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<void> removeUsersFromBlacklist(
      {@required List<String> usernameArray, String appKey}) async {
    await _channel.invokeMethod(
        'removeUsersFromBlacklist',
        {'usernameArray': usernameArray, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<List<JMUserInfo>> getBlacklist() async {
    List userJsons = await _channel.invokeMethod('getBlacklist');
    List<JMUserInfo> res =
        userJsons.map((json) => JMUserInfo.fromJson(json)).toList();
    return res;
  }

  Future<void> setNoDisturb({
    @required dynamic target, // (JMSingle | JMGroup)
    @required bool isNoDisturb,
  }) async {
    var param = target.toJson();
    param['isNoDisturb'] = isNoDisturb;
    await _channel.invokeMethod(
        'setNoDisturb', param..removeWhere((key, value) => value == null));
    return;
  }

  Future<Map> getNoDisturbList() async {
    Map resJson = await _channel.invokeMethod('getNoDisturbList');
    List userJsons = resJson['userInfoArray'];
    List groupJsons = resJson['groupInfoArray'];

    List<JMUserInfo> users =
        userJsons.map((json) => JMUserInfo.fromJson(json)).toList();
    List<JMGroupInfo> groups =
        groupJsons.map((json) => JMGroupInfo.fromJson(json)).toList();

    return {'userInfos': users, 'groupInfos': groups};
  }

  Future<void> setNoDisturbGlobal({@required bool isNoDisturb}) async {
    await _channel.invokeMethod(
        'setNoDisturbGlobal',
        {'isNoDisturb': isNoDisturb}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<bool> isNoDisturbGlobal() async {
    Map resJson = await _channel.invokeMethod('isNoDisturbGlobal');
    return resJson['isNoDisturb'];
  }

  Future<void> blockGroupMessage({
    @required String id,
    @required bool isBlock,
  }) async {
    await _channel.invokeMethod(
        'blockGroupMessage',
        {'id': id, 'isBlock': isBlock}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<bool> isGroupBlocked({
    @required String id,
  }) async {
    Map resJson = await _channel.invokeMethod('isGroupBlocked',
        {'id': id}..removeWhere((key, value) => value == null));
    return resJson['isBlocked'];
  }

  Future<List<JMGroupInfo>> getBlockedGroupList() async {
    List resJson = await _channel.invokeMethod('getBlockedGroupList');
    List<JMGroupInfo> res =
        resJson.map((json) => JMGroupInfo.fromJson(json)).toList();
    return res;
  }

  Future<Map> downloadThumbUserAvatar({
    @required String username,
    String appKey,
  }) async {
    Map resJson = await _channel.invokeMethod(
        'downloadThumbUserAvatar',
        {
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return {
      'username': resJson['username'],
      'appKey': resJson['appKey'],
      'filePath': resJson['filePath']
    };
  }

  Future<Map> downloadOriginalUserAvatar({
    @required String username,
    String appKey,
  }) async {
    Map resJson = await _channel.invokeMethod(
        'downloadOriginalUserAvatar',
        {
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return {
      'username': resJson['username'],
      'appKey': resJson['appKey'],
      'filePath': resJson['filePath']
    };
  }

  /**
   * 下载缩略图
   *
   * @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
   * @param messageId 本地数据库中的消息 id,非 serverMessageId
   *
   * */
  Future<Map> downloadThumbImage({
    @required dynamic target,
    @required String messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod('downloadThumbImage',
        param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  /**
   * 下载原图
   *
   * @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
   * @param messageId 本地数据库中的消息 id,非 serverMessageId
   *
   * */
  Future<Map> downloadOriginalImage({
    @required dynamic target,
    @required String messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod('downloadOriginalImage',
        param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  /**
   * 下载语音
   *
   * @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
   * @param messageId 本地数据库中的消息 id,非 serverMessageId
   *
   * */
  Future<Map> downloadVoiceFile({
    @required dynamic target,
    @required String messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod(
        'downloadVoiceFile', param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  /**
   * 下载文件
   *
   * @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
   * @param messageId 本地数据库中的消息 id
   *
   * */
  Future<Map> downloadFile({
    @required dynamic target,
    @required String messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod(
        'downloadFile', param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  Future<JMConversationInfo> createConversation({
    @required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    Map resJson = await _channel.invokeMethod('createConversation',
        param..removeWhere((key, value) => value == null));

    return JMConversationInfo.fromJson(resJson);
  }

  Future<void> deleteConversation({
    @required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    await _channel.invokeMethod('deleteConversation',
        param..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> enterConversation({
    @required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (_platform.isAndroid) {
      Map param = target.toJson();
      await _channel.invokeMethod('enterConversation',
          param..removeWhere((key, value) => value == null));
    }

    return;
  }

  Future<void> exitConversation({
    @required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (_platform.isAndroid) {
      Map param = target.toJson();
      await _channel.invokeMethod('exitConversation',
          param..removeWhere((key, value) => value == null));
    }

    return;
  }

  Future<JMConversationInfo> getConversation({
    @required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    Map resJson = await _channel.invokeMethod(
        'getConversation', param..removeWhere((key, value) => value == null));

    return JMConversationInfo.fromJson(resJson);
  }

  Future<List<JMConversationInfo>> getConversations() async {
    List conversionJsons = await _channel.invokeMethod('getConversations');
    List<JMConversationInfo> conversations = conversionJsons
        .map((json) => JMConversationInfo.fromJson(json))
        .toList();
    return conversations;
  }

  Future<void> resetUnreadMessageCount({
    @required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    await _channel.invokeMethod('resetUnreadMessageCount',
        param..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> transferGroupOwner({
    @required String groupId,
    @required String username,
    String appKey,
  }) async {
    await _channel.invokeMethod(
        'transferGroupOwner',
        {
          'groupId': groupId,
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> setGroupMemberSilence({
    @required String groupId,
    @required bool isSilence,
    @required String username,
    String appKey,
  }) async {
    await _channel.invokeMethod(
        'setGroupMemberSilence',
        {
          'groupId': groupId,
          'username': username,
          'isSilence': isSilence,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<bool> isSilenceMember({
    @required String groupId,
    @required String username,
    String appKey,
  }) async {
    Map resJson = await _channel.invokeMethod(
        'isSilenceMember',
        {
          'groupId': groupId,
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));
    return resJson['isSilence'];
  }

  Future<List<JMUserInfo>> groupSilenceMembers({
    @required String groupId,
  }) async {
    List memberJsons = await _channel.invokeMethod(
        'groupSilenceMembers',
        {
          'groupId': groupId,
        }..removeWhere((key, value) => value == null));
    List<JMUserInfo> members =
        memberJsons.map((json) => JMUserInfo.fromJson(json)).toList();
    return members;
  }

  Future<void> setGroupNickname({
    @required String groupId,
    @required String nickName,
    @required String username,
    String appKey,
  }) async {
    await _channel.invokeMethod(
        'setGroupNickname',
        {
          'groupId': groupId,
          'nickName': nickName,
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<JMConversationInfo> enterChatRoom({
    @required String roomId,
  }) async {
    Map resJson = await _channel.invokeMethod('enterChatRoom',
        {'roomId': roomId}..removeWhere((key, value) => value == null));

    return JMConversationInfo.fromJson(resJson);
  }

  Future<void> exitChatRoom({
    @required String roomId,
  }) async {
    await _channel.invokeMethod('exitChatRoom',
        {'roomId': roomId}..removeWhere((key, value) => value == null));

    return;
  }

  Future<JMConversationInfo> getChatRoomConversation({
    @required String roomId,
  }) async {
    Map resJson = await _channel.invokeMethod('getChatRoomConversation',
        {'roomId': roomId}..removeWhere((key, value) => value == null));

    return JMConversationInfo.fromJson(resJson);
  }

  Future<List<JMConversationInfo>> getChatRoomConversationList() async {
    List conversationJsons =
        await _channel.invokeMethod('getChatRoomConversationList');
    List<JMConversationInfo> conversations = conversationJsons
        .map((json) => JMConversationInfo.fromJson(json))
        .toList();
    return conversations;
  }

  Future<num> getAllUnreadCount() async {
    num unreadCount = await _channel.invokeMethod('getAllUnreadCount');
    return unreadCount;
  }

  Future<void> addGroupAdmins({
    @required String groupId,
    @required List<String> usernames,
    String appKey,
  }) async {
    await _channel.invokeMethod(
        'addGroupAdmins',
        {'groupId': groupId, 'usernames': usernames, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<void> removeGroupAdmins({
    @required String groupId,
    @required List<String> usernames,
    String appKey,
  }) async {
    await _channel.invokeMethod(
        'removeGroupAdmins',
        {'groupId': groupId, 'usernames': usernames, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<void> changeGroupType({
    @required String groupId,
    @required JMGroupType type,
  }) async {
    await _channel.invokeMethod(
        'changeGroupType',
        {'groupId': groupId, 'type': getStringFromEnum(type)}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<List<JMGroupInfo>> getPublicGroupInfos({
    @required String appKey,
    @required num start,
    @required num count,
  }) async {
    List groupJsons = await _channel.invokeMethod(
        'getPublicGroupInfos',
        {'appKey': appKey, 'start': start, 'count': count}
          ..removeWhere((key, value) => value == null));
    List<JMGroupInfo> groups =
        groupJsons.map((json) => JMGroupInfo.fromJson(json)).toList();
    return groups;
  }

  Future<void> applyJoinGroup({
    @required String groupId,
    String reason,
  }) async {
    await _channel.invokeMethod(
        'applyJoinGroup',
        {'groupId': groupId, 'reason': reason}
          ..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> processApplyJoinGroup({
    @required List<String> events,
    @required bool isAgree,
    @required bool isRespondInviter,
    String reason,
  }) async {
    await _channel.invokeMethod(
        'processApplyJoinGroup',
        {
          'events': events,
          'isAgree': isAgree == 0 ? false : true,
          'isRespondInviter': isRespondInviter == 0 ? false : true,
          'reason': reason
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> dissolveGroup({
    @required String groupId,
  }) async {
    await _channel.invokeMethod(
        'dissolveGroup',
        {
          'groupId': groupId,
        }..removeWhere((key, value) => value == null));

    return;
  }

  /// 会话间透传命令，只支持 single、group，不支持 chatRoom
  Future<void> sendMessageTransCommand({
    @required String message,
    @required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (target is JMChatRoom) {
      print("does not support chatroom message trans.");
      return;
    }

    Map param = target.toJson();
    param["message"] = message;
    param.removeWhere((key, value) => value == null);

    await _channel.invokeMethod('sendMessageTransCommand', param);
  }

  /// 设��间透传命令
  Future<void> sendCrossDeviceTransCommand({
    @required String message,
    @required JMPlatformType platform,
  }) async {
    Map param = Map();
    param["message"] = message;
    param["type"] = getStringFromEnum(platform);
    param.removeWhere((key, value) => value == null);

    await _channel.invokeMethod('sendCrossDeviceTransCommand', param);
  }

  /*
  * 获取 message 当前未发送已读回执的人数
  *
  * @param target 消息所处的会话对象，user or group
  * @param msgId  消息本地 id，即：message.id
  *
  * */
  Future<int> getMessageUnreceiptCount({
    @required dynamic target,

    /// (JMSingle | JMGroup)
    @required String msgId,
  }) async {
    print(flutterLog + "getMessageUnreceiptCount" + " msgid = $msgId");

    if (msgId == null || msgId.length == 0 || target == null) {
      return 0;
    }

    Map param = target.toJson();
    param["id"] = msgId;

    int count = await _channel.invokeMethod('getMessageUnreceiptCount',
        param..removeWhere((key, value) => value == null));
    return count;
  }

  /*
   * 获取 message 已读回执详情
   *
   * @param target    消息所处的会话对象，user or group
   * @param msgId     消息本地 id��即：message.id
   * @param callback  函数回调，返回已发回执和未发回执的 user 列表，如下：
   *                      a = List<JMUserInfo>receiptList
   *                      b = List<JMUserInfo>unreceiptList
   *
   */
  void getMessageReceiptDetails({
    @required dynamic target,

    /// (JMSingle | JMGroup)
    @required String msgId,
    @required JMCallback callback,
  }) async {
    print(flutterLog + "getMessageUnreceiptCount" + " msgid = $msgId");

    if (msgId == null || msgId.length == 0 || target == null) {
      callback(null, null);
      return;
    }

    Map param = target.toJson();
    param["id"] = msgId;

    Map resultMap = await _channel.invokeMethod('getMessageReceiptDetails',
        param..removeWhere((key, value) => value == null));
    if (resultMap != null) {
      List receiptJosnList = resultMap["receiptList"];
      List unreceiptJosnList = resultMap["unreceiptList"];

      List<JMUserInfo> receiptUserList =
          receiptJosnList.map((json) => JMUserInfo.fromJson(json)).toList();
      List<JMUserInfo> unreceiptUserList =
          unreceiptJosnList.map((json) => JMUserInfo.fromJson(json)).toList();
      callback(receiptUserList, unreceiptUserList);
    } else {
      callback(null, null);
    }
  }

  /*
  *  将消息设置为已读
  *  @param target    消息所处的会话对象，user or group
  *  @param msgId     消息本地 id，即：message.id
  *
  *  @return true/false 设置成功返回 true，设置失败返回 false
  * */
  Future<bool> setMessageHaveRead({
    @required dynamic target,

    /// (JMSingle | JMGroup)
    @required String msgId,
  }) async {
    print(flutterLog + "setMessageHaveRead" + " msgid = $msgId");

    if (msgId == null || msgId.length == 0 || target == null) {
      return false;
    }

    Map param = target.toJson();
    param["id"] = msgId;
    bool isSuccess = await _channel.invokeMethod('setMessageHaveRead',
        param..removeWhere((key, value) => value == null));

    return isSuccess;
  }

  /*
  * 获取消息已读状态
  *
  * @param target    消息所处的会话对象，user or group
  * @param msgId     消息本地 id，即：message.id
  *
  * @return
  * */
  Future<bool> getMessageHaveReadStatus({
    @required dynamic target,

    /// (JMSingle | JMGroup)
    @required String msgId,
  }) async {
    print(flutterLog + "getMessageHaveReadStatus" + " msgid = $msgId");

    if (msgId == null || msgId.length == 0 || target == null) {
      return false;
    }

    Map param = target.toJson();
    param["id"] = msgId;
    bool isSuccess = await _channel.invokeMethod('getMessageHaveReadStatus',
        param..removeWhere((key, value) => value == null));

    return isSuccess;
  }
}

enum JMPlatformType { android, ios, windows, web, all }
enum JMConversationType { single, group, chatRoom }

enum JMTargetType { user, group }

// 'male' | 'female' | 'unknown';
enum JMGender { male, female, unknown }

///单聊
class JMSingle {
  ///会话类型
  final JMConversationType type = JMConversationType.single;

  ///昵称
  final String username;

  ///appKey
  final String appKey;

  /// 转为json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': getStringFromEnum(JMConversationType.single),
      'username': username,
      'appKey': appKey
    };
  }

  ///json解析
  JMSingle.fromJson(Map<dynamic, dynamic> json)
      : username = json['username'].toString(),
        appKey = json['appKey'].toString();
}

enum JMGroupType { private, public }

///群聊
class JMGroup {
  ///会话类型
  final JMConversationType type = JMConversationType.group;

  ///群id
  final String groupId;

  @override
  bool operator ==(dynamic other) {
    return other is JMGroup && other.groupId == groupId;
  }

  ///转为json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': getStringFromEnum(JMConversationType.group),
      'groupId': groupId
    };
  }

  ///解析json
  JMGroup.fromJson(Map<dynamic, dynamic> json)
      : groupId = json['groupId'].toString();

  @override
  int get hashCode => super.hashCode;
}

///聊天室
class JMChatRoom {
  ///会话类型
  final JMConversationType type = JMConversationType.chatRoom;

  ///聊天室id
  final String roomId;

  @override
  bool operator ==(dynamic other) {
    return other is JMChatRoom && other.roomId == roomId;
  }

  ///
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': getStringFromEnum(JMConversationType.chatRoom),
      'roomId': roomId
    };
  }

  JMChatRoom.fromJson(Map<dynamic, dynamic> json) : roomId = json['roomId'];

  @override
  int get hashCode => super.hashCode;
}

// export type JMAllType = (JMSingle | JMGroup | JMChatRoom);

class JMMessageSendOptions {
  /// 接收方是否针对此次消息发送展示通知栏通知。
  /// @defaultvalue
  bool isShowNotification;

  ///  是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。
  ///  @defaultvalue
  bool isRetainOffline;

  bool isCustomNotificationEnabled;

  /// 设置此条消息在��收方通知栏所展示通知的标题。
  String notificationTitle;

  /// 设置此条消息在接收方通��栏所展示通知的内容。
  String notificationText;

  /// ��置这条消息的发送是否需要对方发送已读回执，false，默认值
  bool needReadReceipt = false;

  Map toJson() {
    return {
      'isShowNotification': isShowNotification,
      'isRetainOffline': isRetainOffline,
      'isCustomNotificationEnabled': isCustomNotificationEnabled,
      'notificationTitle': notificationTitle,
      'notificationText': notificationText,
      'needReadReceipt': needReadReceipt,
    };
  }

  JMMessageSendOptions.fromJson(Map<dynamic, dynamic> json)
      : isShowNotification = json['isShowNotification'],
        isRetainOffline = json['isRetainOffline'],
        isCustomNotificationEnabled = json['isCustomNotificationEnabled'],
        notificationTitle = json['notificationTitle'],
        notificationText = json['notificationText'],
        needReadReceipt = json['needReadReceipt'];
}

class JMMessageOptions {
  Map<dynamic, dynamic> extras;
  JMMessageSendOptions messageSendingOptions;

  Map toJson() {
    return {
      'extras': extras,
      'messageSendingOptions': messageSendingOptions.toJson()
    };
  }
}

class JMError {
  String code;
  String description;

  Map toJson() {
    return {
      'code': code,
      'description': description,
    };
  }

  JMError.fromJson(Map<dynamic, dynamic> json)
      : code = json['code'],
        description = json['description'];
}

class JMUserInfo {
  JMTargetType type = JMTargetType.user;

  String username; // 用户名
  String appKey; // 用户所属应用的 appKey，可与 username 共同作为用户的唯一标识
  String nickname; // 昵称
  JMGender gender; // 性别
  String avatarThumbPath; // 头像的缩略图地址
  String birthday; // 日期的毫秒数
  String region; // 地区
  String signature; // 个性签���
  String address; // ���体地址
  String noteName; // 备注名
  String noteText; // 备���信息
  bool isNoDisturb; // 是否免打扰
  bool isInBlackList; // 是否在黑名单中
  bool isFriend; // 是否为好友
  Map<dynamic, dynamic> extras; // 自定义键值对

  JMSingle get targetType =>
      JMSingle.fromJson({'username': username, 'appKey': appKey});

  bool operator ==(dynamic other) {
    return (other is JMUserInfo && other.username == username);
  }

  Map toJson() {
    return {
      'type': getStringFromEnum(type),
      'gender': getStringFromEnum(gender),
      'username': username,
      'appKey': appKey,
      'nickname': nickname,
      'avatarThumbPath': avatarThumbPath,
      'birthday': birthday,
      'region': region,
      'signature': signature,
      'address': address,
      'noteName': noteName,
      'noteText': noteText,
      'isNoDisturb': isNoDisturb,
      'isInBlackList': isInBlackList,
      'isFriend': isFriend,
      'extras': extras
    };
  }

  JMUserInfo.fromJson(Map<dynamic, dynamic> json)
      : username = json['username'],
        appKey = json['appKey'],
        nickname = json['nickname'],
        avatarThumbPath = json['avatarThumbPath'],
        birthday = json['birthday'],
        region = json['region'],
        signature = json['signature'],
        address = json['address'],
        noteName = json['noteName'],
        noteText = json['noteText'],
        isNoDisturb = json['isNoDisturb'],
        isInBlackList = json['isInBlackList'],
        isFriend = json['isFriend'],
        gender = getEnumFromString(JMGender.values, json['gender']),
        extras = json['extras'];

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

enum JMLoginStateChangedType {
  user_logout, // 被踢、被迫退出
  user_deleted, // 用户被删除
  user_password_change, // 非客户端修改密码
  user_login_status_unexpected, // 用户登录状态异常
  user_disabled //用户被禁用
}

enum JMContactNotifyType {
  invite_received,
  invite_accepted,
  invite_declined,
  contact_deleted
}

class JMContactNotifyEvent {
  JMContactNotifyType type;
  String reason;
  String fromUserName;
  String fromUserAppKey;

  Map toJson() {
    return {
      'type': getStringFromEnum(type),
      'reason': reason,
      'fromUserName': fromUserName,
      'fromUserAppKey': fromUserAppKey
    };
  }

  JMContactNotifyEvent.fromJson(Map<dynamic, dynamic> json)
      : type = getEnumFromString(JMContactNotifyType.values, json['type']),
        reason = json['reason'],
        fromUserName = json['fromUsername'],
        fromUserAppKey = json['fromUserAppKey'];
}

class JMReceiveTransCommandEvent {
  String message;
  JMUserInfo sender;
  dynamic receiver; // JMUserInfo | JMGroupInfo;
  JMTargetType receiverType; // user | group // DIFFerent

  Map toJson() {
    return {
      'message': message,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'receiverType': getStringFromEnum(receiverType)
    };
  }

  JMReceiveTransCommandEvent.fromJson(Map<dynamic, dynamic> json)
      : receiverType =
            getEnumFromString(JMTargetType.values, json['receiverType']),
        message = json['message'],
        sender = JMUserInfo.fromJson(json['sender']) {
    switch (receiverType) {
      case JMTargetType.user:
        receiver = JMUserInfo.fromJson(json['receiver']);
        break;
      case JMTargetType.group:
        receiver = JMGroupInfo.fromJson(json['receiver']);
        break;
    }
  }
}

class JMReceiveApplyJoinGroupApprovalEvent {
  String eventId;
  String groupId;
  bool isInitiativeApply;
  JMUserInfo sendApplyUser;
  List<JMUserInfo> joinGroupUsers;
  String reason;

  JMReceiveApplyJoinGroupApprovalEvent.fromJson(Map<dynamic, dynamic> json)
      : eventId = json['eventId'],
        groupId = json['groupId'],
        isInitiativeApply = json['isInitiativeApply'],
        sendApplyUser = JMUserInfo.fromJson(json['sendApplyUser']),
        reason = json['reason'] {
    List<dynamic> userJsons = json['joinGroupUsers'];
    joinGroupUsers = userJsons.map((userJson) {
      return JMUserInfo.fromJson(userJson);
    }).toList();
  }
}

class JMReceiveGroupAdminRejectEvent {
  String groupId;
  JMUserInfo groupManager;
  String reason;

  JMReceiveGroupAdminRejectEvent.fromJson(Map<dynamic, dynamic> json)
      : groupId = json['groupId'],
        groupManager = JMUserInfo.fromJson(json['groupManager']),
        reason = json['reason'];
}

class JMReceiveGroupAdminApprovalEvent {
  bool isAgree;
  String applyEventId;
  String groupId;
  JMUserInfo groupAdmin;
  List<JMUserInfo> users;

  JMReceiveGroupAdminApprovalEvent.fromJson(Map<dynamic, dynamic> json)
      : isAgree = json['isAgree'],
        applyEventId = json['applyEventId'],
        groupId = json['groupId'],
        groupAdmin = JMUserInfo.fromJson(json['groupAdmin']) {
    List<dynamic> userJsons = json['users'];
    users = userJsons.map((userJson) {
      return JMUserInfo.fromJson(userJson);
    }).toList();
  }
}

class JMGroupInfo {
  String id; // 群组 id
  String name; // 群组名称
  String desc; // 群组描述
  int level; // 群组等级，默认等级 4
  String owner; // 群主的 username
  String ownerAppKey; // 群主的 appKey
  int maxMemberCount; // 最大成员数
  bool isNoDisturb; // 是否免打扰
  bool isBlocked; // 是否屏蔽群消息
  JMGroupType groupType; // 群类型
  JMGroup get targetType => JMGroup.fromJson({'groupId': id});

  bool operator ==(dynamic other) {
    return (other is JMGroupInfo && other.id == id);
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'level': level,
      'owner': owner,
      'ownerAppKey': ownerAppKey,
      'maxMemberCount': maxMemberCount,
      'isNoDisturb': isNoDisturb,
      'isBlocked': isBlocked,
      'groupType': getStringFromEnum(groupType),
    };
  }

  JMGroupInfo.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'],
        desc = json['desc'],
        level = json['level'],
        owner = json['owner'],
        ownerAppKey = json['ownerAppKey'],
        maxMemberCount = json['maxMemberCount'],
        isNoDisturb = json['isNoDisturb'],
        isBlocked = json['isBlocked'],
        groupType = getEnumFromString(JMGroupType.values, json['groupType']);

  Future<void> exitGroup({@required String id}) async {
    await JmessageFlutter().exitGroup(id: id);
    return;
  }

  Future<void> updateGroupInfo({
    String newName,
    String newDesc,
  }) async {
    await JmessageFlutter().updateGroupInfo(
      id: id,
      newDesc: newDesc,
      newName: newName,
    );
    return;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

enum JMGroupMemberType {
  owner, // 群主
  admin, // 管理员
  ordinary // 普通成员
}

class JMGroupMemberInfo {
  JMUserInfo user;
  String groupNickname;
  JMGroupMemberType memberType;
  num joinGroupTime;

  Map toJson() {
    return {
      'user': user.toJson(),
      'groupNickname': groupNickname,
      'memberType': getStringFromEnum(memberType),
      'joinGroupTime': joinGroupTime
    };
  }

  JMGroupMemberInfo.fromJson(Map<dynamic, dynamic> json)
      : user = JMUserInfo.fromJson(json['user']),
        groupNickname = json['groupNickname'],
        memberType =
            getEnumFromString(JMGroupMemberType.values, json['memberType']),
        joinGroupTime = json['joinGroupTime'];
}

class JMChatRoomInfo {
  String roomId; // 聊天室 id
  String name; // 聊天室名称
  String appKey; // 聊天室所属应用的 App Key
  String description; // 聊天室描述信息
  int createTime; // 创建日期，单位：秒
  int maxMemberCount; // 最大成员数
  int memberCount; // 当前成员数

  JMChatRoom get targetType => JMChatRoom.fromJson({'roomId': roomId});

  bool operator ==(dynamic other) {
    return (other is JMChatRoomInfo && other.roomId == roomId);
  }

  Map toJson() {
    return {
      'roomId': roomId,
      'name': name,
      'appKey': appKey,
      'description': description,
      'createTime': createTime,
      'maxMemberCount': maxMemberCount,
      'memberCount': memberCount,
    };
  }

  JMChatRoomInfo.fromJson(Map<dynamic, dynamic> json)
      : roomId = json['roomId'],
        name = json['name'],
        appKey = json['appKey'],
        description = json['description'],
        createTime = json['createTime'],
        maxMemberCount = json['maxMemberCount'],
        memberCount = json['memberCount'];

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

///会话信息
class JMConversationInfo {
  /// 会话类型
  final JMConversationType conversationType;

  /// 会话标题
  final String title;

  /// 未读消息数
  final int unreadCount;

  /// JMUserInfo or JMGroupInfo or JMChatRoom
  late final dynamic target;

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

  ///
  bool isMyMessage(JMNormalMessage message) {
    // TODO:
    return target == message.target;
  }

  ///
  Future<void> setExtras(Map<String, dynamic> extras) async {
    this.extras.addAll(extras);
    await JmessageFlutter().setConversationExtras(
      type: target.targetType,
      extras: extras,
    );
  }

  // sendText
  Future<JMTextMessage> sendTextMessage({
    required String text,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    final JMTextMessage msg = await JmessageFlutter().sendTextMessage(
        type: target.targetType,
        text: text,
        sendOption: sendOption,
        extras: extras);
    return msg;
  }

  // sendImage
  Future<JMImageMessage> sendImageMessage({
    @required String path,
    JMMessageSendOptions sendOption,
    Map<dynamic, dynamic> extras,
  }) async {
    JMImageMessage msg = await JmessageFlutter().sendImageMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // sendVoice
  Future<JMVoiceMessage> sendVoiceMessage({
    @required String path,
    JMMessageSendOptions sendOption,
    Map<dynamic, dynamic> extras,
  }) async {
    JMVoiceMessage msg = await JmessageFlutter().sendVoiceMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // sendCustom
  Future<JMCustomMessage> sendCustomMessage({
    @required Map<dynamic, dynamic> customObject,
    JMMessageSendOptions sendOption,
    Map<dynamic, dynamic> extras,
  }) async {
    JMCustomMessage msg = await JmessageFlutter().sendCustomMessage(
      type: target.targetType,
      customObject: customObject,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // sendLocation
  Future<JMLocationMessage> sendLocationMessage({
    @required double latitude,
    @required double longitude,
    @required int scale,
    String address,
    JMMessageSendOptions sendOption,
    Map<dynamic, dynamic> extras,
  }) async {
    JMLocationMessage msg = await JmessageFlutter().sendLocationMessage(
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

  // sendFile
  Future<JMFileMessage> sendFileMessage({
    @required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    @required String path,
    JMMessageSendOptions sendOption,
    Map<dynamic, dynamic> extras,
  }) async {
    JMFileMessage msg = await JmessageFlutter().sendFileMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // getHistoryMessages
  Future<List> getHistoryMessages(
      {@required int from, @required int limit, bool isDescend = false}) async {
    List msgs = await JmessageFlutter().getHistoryMessages(
        type: target.targetType,
        from: from,
        limit: limit,
        isDescend: isDescend);
    return msgs;
  }
}
