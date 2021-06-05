import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bean/conversation_info.dart';
import 'bean/conversation_type.dart';
import 'bean/event.dart';
import 'bean/group_member_info.dart';
import 'bean/jm_info.dart';
import 'bean/jmessage_value.dart';
import 'bean/message.dart';
import 'bean/offline_message.dart';
import 'bean/send_options.dart';
import 'enum/jmessage_enum.dart';

///单例
_JMessage jMessage = _JMessage();

class _JMessage extends ValueNotifier<JMessageValue> {
  final MethodChannel _channel = const MethodChannel('jmessage_flutter');

  ///
  _JMessage() : super(JMessageValue()) {
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
        final List<JMNormalMessage> messages =
            (param['messageArray'] as List<dynamic>)
                .map((dynamic e) => e as Map<String, dynamic>)
                .map<JMNormalMessage>(
                    (Map<String, dynamic> e) => JMNormalMessage.cast(e))
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
      {required ConversationType type, Map<dynamic, dynamic>? extras}) async {
    final Map<String, dynamic> param = type.toJson();
    param['extras'] = extras;
    final Map<String, dynamic>? resMap = await _channel
        .invokeMapMethod<String, dynamic>('setConversationExtras', param);
    final JMConversationInfo res = JMConversationInfo.fromJson(resMap!);
    return res;
  }

  ///创建消息
  Future<dynamic> createMessage({
    /// 消息类型
    required JMMessageType type,
    required ConversationType targetType,
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
    final Map<String, dynamic> param = targetType.toJson();

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
      {required ConversationType type,
      required JMMessageSendOptions? sendOption,
      required Map<String, dynamic>? extras}) {
    final Map<String, dynamic> param = type.toJson();

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
    final Map<String, dynamic> param = message.target.targetType.toJson();

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
    required ConversationType type,
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
    required ConversationType type,
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
    required ConversationType type,
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
    required ConversationType type,

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
    required ConversationType type,
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
    required ConversationType type,
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
    required ConversationType target,

    /// (JMSingle | JMGroup )
    required String serverMessageId,
  }) async {
    final Map<String, dynamic> param = target.toJson();
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
      {required ConversationType type,
      required int from,
      required int limit,
      bool isDescend = false}) async {
    final Map<String, dynamic> param = type.toJson();
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
    required ConversationType type,
    required String messageId,
  }) async {
    final Map<String, dynamic> param = type.toJson();

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
    required ConversationType type,
    required String messageId,
  }) async {
    final Map<String, dynamic> param = type.toJson();
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
    final List<Map<String, dynamic>>? membersJsons = await _channel
        .invokeMethod('getGroupMembers', <String, dynamic>{'id': id});

    final List<JMGroupMemberInfo> res = membersJsons!
        .map((Map<String, dynamic> memberJson) =>
            JMGroupMemberInfo.fromJson(memberJson))
        .toList();
    return res;
  }

  ///添加到黑名单
  Future<void> addUsersToBlacklist(
      {required List<String> usernameArray, String? appKey}) async {
    return await _channel.invokeMethod('addUsersToBlacklist',
        <String, dynamic>{'usernameArray': usernameArray, 'appKey': appKey});
  }

  ///从黑名单中移除
  Future<void> removeUsersFromBlacklist(
      {required List<String> usernameArray, String? appKey}) async {
    return await _channel.invokeMethod('removeUsersFromBlacklist',
        <String, dynamic>{'usernameArray': usernameArray, 'appKey': appKey});
  }

  ///获取黑名单列表
  Future<List<JMUserInfo>> getBlacklist() async {
    final List<Map<String, dynamic>>? userJsons =
        await _channel.invokeListMethod<Map<String, dynamic>>('getBlacklist');
    final List<JMUserInfo> res = userJsons!
        .map((Map<String, dynamic> json) => JMUserInfo.fromJson(json))
        .toList();
    return res;
  }

  ///设置免打扰
  Future<void> setNoDisturb({
    required dynamic target, // (JMSingle | JMGroup)
    required bool isNoDisturb,
  }) async {
    Map<String, dynamic> param = <String, dynamic>{};
    if (target is JMSingle) {
      param = target.toJson();
    } else if (target is JMGroup) {
      param = target.toJson();
    }
    param['isNoDisturb'] = isNoDisturb;
    return await _channel.invokeMethod('setNoDisturb', param);
  }

  ///获取免打扰列表
  Future<Map<String, List<dynamic>>> getNoDisturbList() async {
    final Map<String, dynamic>? resJson =
        await _channel.invokeMapMethod<String, dynamic>('getNoDisturbList');
    final List<Map<String, dynamic>> userJsons =
        (resJson!['userInfoArray'] as List<dynamic>)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
    final List<Map<String, dynamic>> groupJsons =
        (resJson['groupInfoArray'] as List<dynamic>)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();

    final List<JMUserInfo> users = userJsons
        .map((Map<String, dynamic> json) => JMUserInfo.fromJson(json))
        .toList();
    final List<JMGroupInfo> groups = groupJsons
        .map((Map<String, dynamic> json) => JMGroupInfo.fromJson(json))
        .toList();

    return <String, List<dynamic>>{'userInfos': users, 'groupInfos': groups};
  }

  ///设置全局免打扰
  Future<void> setNoDisturbGlobal({required bool isNoDisturb}) async {
    return await _channel.invokeMethod(
        'setNoDisturbGlobal', <String, bool>{'isNoDisturb': isNoDisturb});
  }

  ///是否为全局免打扰
  Future<bool> isNoDisturbGlobal() async {
    final Map<String, bool>? resJson =
        await _channel.invokeMethod('isNoDisturbGlobal');
    final bool? b = resJson!['isNoDisturb'];
    return b!;
  }

  ///是否接收群消息
  Future<void> blockGroupMessage({
    required String id,
    required bool isBlock,
  }) async {
    return await _channel.invokeMethod(
        'blockGroupMessage', <String, dynamic>{'id': id, 'isBlock': isBlock});
  }

  ///是否已禁止接收群消息
  Future<bool> isGroupBlocked({
    required String id,
  }) async {
    final Map<String, dynamic>? resJson = await _channel
        .invokeMapMethod<String, dynamic>(
            'isGroupBlocked', <String, dynamic>{'id': id});
    final bool? result = resJson!['isBlocked'] as bool;
    return result!;
  }

  ///获取禁止接收消息的群列表
  Future<List<JMGroupInfo>> getBlockedGroupList() async {
    final List<Map<String, dynamic>>? resJson = await _channel
        .invokeListMethod<Map<String, dynamic>>('getBlockedGroupList');
    final List<JMGroupInfo> res = resJson!
        .map((Map<String, dynamic> json) => JMGroupInfo.fromJson(json))
        .toList();
    return res;
  }

  ///下载用户头像缩略图
  Future<Map<String, dynamic>> downloadThumbUserAvatar({
    required String username,
    String? appKey,
  }) async {
    final Map<String, dynamic>? resJson = await _channel
        .invokeMapMethod<String, dynamic>(
            'downloadThumbUserAvatar', <String, dynamic>{
      'username': username,
      'appKey': appKey,
    });

    return <String, dynamic>{
      'username': resJson!['username'],
      'appKey': resJson['appKey'],
      'filePath': resJson['filePath']
    };
  }

  ///下载头像原始图片
  Future<Map<String, dynamic>> downloadOriginalUserAvatar({
    required String username,
    String? appKey,
  }) async {
    final Map<String, dynamic>? resJson = await _channel
        .invokeMethod('downloadOriginalUserAvatar', <String, dynamic>{
      'username': username,
      'appKey': appKey,
    });

    return <String, dynamic>{
      'username': resJson!['username'],
      'appKey': resJson['appKey'],
      'filePath': resJson['filePath']
    };
  }

  /// 下载缩略图
  ///
  /// @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// @param messageId 本地数据库中的消息 id,非 serverMessageId
  ///
  Future<Map<String, dynamic>> downloadThumbImage({
    required ConversationType target,
    required String messageId,
  }) async {
    final Map<String, dynamic> param = target.toJson();

    param['messageId'] = messageId;
    final Map<String, dynamic>? resJson = await _channel
        .invokeMapMethod<String, dynamic>('downloadThumbImage', param);

    return <String, dynamic>{
      'messageId': resJson!['messageId'],
      'filePath': resJson['filePath']
    };
  }

  /// 下载原图
  ///
  /// @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// @param messageId 本地数据库中的消息 id,非 serverMessageId
  ///
  Future<Map<String, dynamic>> downloadOriginalImage({
    required ConversationType target,
    required String messageId,
  }) async {
    final Map<String, dynamic> param = target.toJson();
    param['messageId'] = messageId;
    final Map<String, dynamic>? resJson = await _channel
        .invokeMapMethod<String, dynamic>('downloadOriginalImage', param);

    return <String, dynamic>{
      'messageId': resJson!['messageId'],
      'filePath': resJson['filePath']
    };
  }

  /// 下载语音
  ///
  /// @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// @param messageId 本地数据库中的消息 id,非 serverMessageId
  ///
  Future<Map<String, dynamic>> downloadVoiceFile({
    required ConversationType target,
    required String messageId,
  }) async {
    final Map<String, dynamic> param = target.toJson();

    param['messageId'] = messageId;
    final Map<String, dynamic>? resJson = await _channel
        .invokeMapMethod<String, dynamic>('downloadVoiceFile', param);

    return <String, dynamic>{
      'messageId': resJson!['messageId'],
      'filePath': resJson['filePath']
    };
  }

  /// 下载文件
  ///
  /// @param target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// @param messageId 本地数据库中的消息 id
  ///
  Future<Map<String, dynamic>> downloadFile({
    required ConversationType target,
    required String messageId,
  }) async {
    final Map<String, dynamic> param = target.toJson();

    param['messageId'] = messageId;
    final Map<String, dynamic>? resJson =
        await _channel.invokeMapMethod<String, dynamic>('downloadFile', param);

    return <String, dynamic>{
      'messageId': resJson!['messageId'],
      'filePath': resJson['filePath']
    };
  }

  ///创建会话  [target]: ([JMSingle] | [JMGroup] | [JMChatRoom])
  Future<JMConversationInfo> createConversation({
    required ConversationType target,
  }) async {
    final Map<String, dynamic>? resJson =
        await _channel.invokeMapMethod<String, dynamic>(
            'createConversation', target.toJson());

    return JMConversationInfo.fromJson(resJson!);
  }

  ///删除会话 [target]: ([JMSingle] | [JMGroup] | [JMChatRoom])
  Future<void> deleteConversation({
    required ConversationType target,
  }) async {
    return await _channel.invokeMethod('deleteConversation', target.toJson());
  }

  ///进入会话  only Android    [target]: ([JMSingle] | [JMGroup])
  Future<void> enterConversation({
    required ConversationType target,
  }) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('enterConversation', target.toJson());
    }

    return;
  }

  ///退出会话 only Android    [target]: ([JMSingle] | [JMGroup])
  Future<void> exitConversation({
    required ConversationType target,
  }) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('exitConversation', target.toJson());
    }

    return;
  }

  ///获取会话信息   [target]: ([JMSingle] | [JMGroup] | [JMChatRoom])
  Future<JMConversationInfo> getConversation({
    required ConversationType target,
  }) async {
    final Map<String, dynamic>? resJson =
        await _channel.invokeMethod('getConversation', target.toJson());

    return JMConversationInfo.fromJson(resJson!);
  }

  ///获取会话列表
  Future<List<JMConversationInfo>> getConversations() async {
    final List<Map<String, dynamic>>? conversionJsons = await _channel
        .invokeListMethod<Map<String, dynamic>>('getConversations');
    final List<JMConversationInfo> conversations = conversionJsons!
        .map((Map<String, dynamic> json) => JMConversationInfo.fromJson(json))
        .toList();
    return conversations;
  }

  ///重置未读消息条数   [target]: ([JMSingle] | [JMGroup] | [JMChatRoom])
  Future<void> resetUnreadMessageCount({
    required ConversationType target,
  }) async {
    return await _channel.invokeMethod(
        'resetUnreadMessageCount', target.toJson());
  }

  ///转让群主
  Future<void> transferGroupOwner({
    required String groupId,
    required String username,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('transferGroupOwner', <String, dynamic>{
      'groupId': groupId,
      'username': username,
      'appKey': appKey,
    });
  }

  ///设置指定[username]群成员禁言
  Future<void> setGroupMemberSilence({
    required String groupId,
    required bool isSilence,
    required String username,
    String? appKey,
  }) async {
    return await _channel
        .invokeMethod('setGroupMemberSilence', <String, dynamic>{
      'groupId': groupId,
      'username': username,
      'isSilence': isSilence,
      'appKey': appKey,
    });
  }

  ///指定群成员是否已被禁言
  Future<bool> isSilenceMember({
    required String groupId,
    required String username,
    String? appKey,
  }) async {
    final Map<String, dynamic>? resJson =
        await _channel.invokeMethod('isSilenceMember', <String, dynamic>{
      'groupId': groupId,
      'username': username,
      'appKey': appKey,
    });
    return resJson!['isSilence'] as bool;
  }

  ///群全员禁言
  Future<List<JMUserInfo>> groupSilenceMembers({
    required String groupId,
  }) async {
    final List<Map<String, dynamic>>? memberJsons = await _channel
        .invokeListMethod<Map<String, dynamic>>(
            'groupSilenceMembers', <String, dynamic>{
      'groupId': groupId,
    });
    final List<JMUserInfo> members = memberJsons!
        .map((Map<String, dynamic> json) => JMUserInfo.fromJson(json))
        .toList();
    return members;
  }

  ///设置群昵称
  Future<void> setGroupNickname({
    required String groupId,
    required String nickName,
    required String username,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('setGroupNickname', <String, dynamic>{
      'groupId': groupId,
      'nickName': nickName,
      'username': username,
      'appKey': appKey,
    });
  }

  ///进入聊天室
  Future<JMConversationInfo> enterChatRoom({
    required String roomId,
  }) async {
    final Map<String, dynamic>? resJson = await _channel
        .invokeMapMethod<String, dynamic>(
            'enterChatRoom', <String, dynamic>{'roomId': roomId});

    return JMConversationInfo.fromJson(resJson!);
  }

  ///退出聊天室
  Future<void> exitChatRoom({
    required String roomId,
  }) async {
    return await _channel
        .invokeMethod('exitChatRoom', <String, dynamic>{'roomId': roomId});
  }

  ///获取聊天室会话
  Future<JMConversationInfo> getChatRoomConversation({
    required String roomId,
  }) async {
    final Map<String, dynamic>? resJson = await _channel
        .invokeMapMethod<String, dynamic>(
            'getChatRoomConversation', <String, dynamic>{'roomId': roomId});

    return JMConversationInfo.fromJson(resJson!);
  }

  ///获取聊天室会话列表
  Future<List<JMConversationInfo>> getChatRoomConversationList() async {
    final List<Map<String, dynamic>>? conversationJsons = await _channel
        .invokeListMethod<Map<String, dynamic>>('getChatRoomConversationList');
    final List<JMConversationInfo> conversations = conversationJsons!
        .map((Map<String, dynamic> json) => JMConversationInfo.fromJson(json))
        .toList();
    return conversations;
  }

  ///获取未读消息的总条数
  Future<int> getAllUnreadCount() async {
    final int? unreadCount =
        await _channel.invokeMethod<int>('getAllUnreadCount');
    return unreadCount!;
  }

  ///添加群管理员
  Future<void> addGroupAdmins({
    required String groupId,
    required List<String> usernames,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('addGroupAdmins', <String, dynamic>{
      'groupId': groupId,
      'usernames': usernames,
      'appKey': appKey
    });
  }

  ///移除群管理员
  Future<void> removeGroupAdmins({
    required String groupId,
    required List<String> usernames,
    String? appKey,
  }) async {
    return await _channel.invokeMethod('removeGroupAdmins', <String, dynamic>{
      'groupId': groupId,
      'usernames': usernames,
      'appKey': appKey
    });
  }

  ///修改群类型
  Future<void> changeGroupType({
    required String groupId,
    required JMGroupType type,
  }) async {
    return await _channel.invokeMethod('changeGroupType',
        <String, dynamic>{'groupId': groupId, 'type': getStringFromEnum(type)});
  }

  ///获取公开群信息列表
  Future<List<JMGroupInfo>> getPublicGroupInfos({
    required String appKey,
    required num start,
    required num count,
  }) async {
    final List<Map<String, dynamic>>? groupJsons = await _channel
        .invokeListMethod<Map<String, dynamic>>(
            'getPublicGroupInfos', <String, dynamic>{
      'appKey': appKey,
      'start': start,
      'count': count
    });
    final List<JMGroupInfo> groups = groupJsons!
        .map((Map<String, dynamic> json) => JMGroupInfo.fromJson(json))
        .toList();
    return groups;
  }

  ///申请加入群组
  Future<void> applyJoinGroup({
    required String groupId,
    String? reason,
  }) async {
    return await _channel.invokeMethod('applyJoinGroup',
        <String, dynamic>{'groupId': groupId, 'reason': reason});
  }

  ///处理群组加入申请
  Future<void> processApplyJoinGroup({
    required List<String> events,
    required bool isAgree,
    required bool isRespondInviter,
    String? reason,
  }) async {
    return await _channel
        .invokeMethod('processApplyJoinGroup', <String, dynamic>{
      'events': events,
      'isAgree': isAgree,
      'isRespondInviter': isRespondInviter,
      'reason': reason
    });
  }

  ///解散群组
  Future<void> dissolveGroup({
    required String groupId,
  }) async {
    return await _channel.invokeMethod('dissolveGroup', <String, String>{
      'groupId': groupId,
    });
  }

  /// 会话间透传命令，只支持 single、group，不支持 chatRoom
  Future<void> sendMessageTransCommand({
    required String message,
    required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (target is JMChatRoom) {
      print('does not support chatroom message trans.');
      return;
    }

    Map<String, dynamic> param = <String, dynamic>{};
    if (target is JMSingle) {
      param = target.toJson();
    } else if (target is JMGroup) {
      param = target.toJson();
    }
    param['message'] = message;

    return await _channel.invokeMethod('sendMessageTransCommand', param);
  }

  /// 设备间透传命令
  Future<void> sendCrossDeviceTransCommand({
    required String message,
    required JMPlatformType platform,
  }) async {
    final Map<String, dynamic> param = <String, dynamic>{};
    param['message'] = message;
    param['type'] = getStringFromEnum(platform);

    return await _channel.invokeMethod('sendCrossDeviceTransCommand', param);
  }

  ///  获取 message 当前未发送已读回执的人数
  /// [target] 消息所处的会话对象，user or group ([JMSingle] | [JMGroup])
  /// [msgId]  消息本地 id，即：message.id
  Future<int> getMessageUnreceiptCount({
    required ConversationType target,
    required String msgId,
  }) async {
    final Map<String, dynamic> param = target.toJson();
    param['id'] = msgId;

    final int? count =
        await _channel.invokeMethod<int>('getMessageUnreceiptCount', param);
    return count!;
  }

  /// 获取 message 已读回执详情
  /// [target]    消息所处的会话对象，user or group  ([JMSingle] | [JMGroup])
  /// [msgId]     消息本地 即：message.id
  /// [callback]  函数回调，返回已发回执和未发回执的 user 列表，如下：
  ///                         a = List<JMUserInfo>receiptList
  ///                         b = List<JMUserInfo>unreceiptList
  void getMessageReceiptDetails({
    required ConversationType target,
    required String msgId,
    required JMCallback callback,
  }) async {
    final Map<String, dynamic> param = target.toJson();
    param['id'] = msgId;

    final Map<String, dynamic>? resultMap = await _channel
        .invokeMapMethod<String, dynamic>('getMessageReceiptDetails', param);
    if (resultMap != null) {
      final List<Map<String, dynamic>> receiptJsonList =
          (resultMap['receiptList'] as List<dynamic>)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
      final List<Map<String, dynamic>> unreceiptJsonList =
          (resultMap['unreceiptList'] as List<dynamic>)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();

      final List<JMUserInfo> receiptUserList = receiptJsonList
          .map((Map<String, dynamic> json) => JMUserInfo.fromJson(json))
          .toList();
      final List<JMUserInfo> unreceiptUserList = unreceiptJsonList
          .map((Map<String, dynamic> json) => JMUserInfo.fromJson(json))
          .toList();
      callback(receiptUserList, unreceiptUserList);
    } else {
      callback(null, null);
    }
  }

  ///将消息设置为已读
  /// [target]    消息所处的会话对象，user or group  ([JMSingle] | [JMGroup])
  ///  [msgId]     消息本地 id，即：message.id
  ///
  ///   true/false 设置成功返回 true，设置失败返回 false
  Future<bool> setMessageHaveRead({
    required ConversationType target,
    required String msgId,
  }) async {
    final Map<String, dynamic> param = target.toJson();
    param['id'] = msgId;
    final bool? isSuccess =
        await _channel.invokeMethod<bool>('setMessageHaveRead', param);

    return isSuccess!;
  }

  /// 获取消息已读状态
  /// [target]    消息所处的会话对象，user or group ([JMSingle] | [JMGroup])
  /// [msgId]     消息本地 id，即：message.id
  Future<bool> getMessageHaveReadStatus({
    required ConversationType target,

    /// (JMSingle | JMGroup)
    required String msgId,
  }) async {
    final Map<String, dynamic> param = target.toJson();
    param['id'] = msgId;
    final bool? isSuccess =
        await _channel.invokeMethod<bool>('getMessageHaveReadStatus', param);

    return isSuccess!;
  }
}
