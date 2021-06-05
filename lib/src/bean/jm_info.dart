import 'package:jmessage_flutter/src/enum/jmessage_enum.dart';
import 'package:jmessage_flutter/src/jmessage.dart';

import 'conversation_type.dart';

///基础信息类
abstract class BaseInfo {
  ///构造传入会话类型
  BaseInfo(this.targetType);

  ///会话类型
  final ConversationType targetType;

  ///解析json
  Map<String, dynamic> toJson();
}

///用户信息
class JMUserInfo extends BaseInfo {
  ///
  JMUserInfo.fromJson(Map<dynamic, dynamic> json)
      : username = json['username'].toString(),
        appKey = json['appKey'].toString(),
        nickname = json['nickname'].toString(),
        avatarThumbPath = json['avatarThumbPath'].toString(),
        birthday = json['birthday'].toString(),
        region = json['region'].toString(),
        signature = json['signature'].toString(),
        address = json['address'].toString(),
        noteName = json['noteName'].toString(),
        noteText = json['noteText'].toString(),
        isNoDisturb = json['isNoDisturb'] as bool,
        isInBlackList = json['isInBlackList'] as bool,
        isFriend = json['isFriend'] as bool,
        gender = getEnumFromString(JMGender.values, json['gender'].toString()),
        extras = json['extras'] as Map<String, dynamic>,
        super(JMSingle(
            username: json['username'].toString(),
            appKey: json['appKey'].toString()));

  ///目标类型
  final JMTargetType type = JMTargetType.user;

  /// 用户名
  final String username;

  /// 用户所属应用的 appKey，可与 username 共同作为用户的唯一标识
  final String appKey;

  /// 昵称
  final String nickname;

  /// 性别
  final JMGender gender;

  /// 头像的缩略图地址
  final String avatarThumbPath;

  /// 日期的毫秒数
  final String birthday;

  /// 地区
  final String region;

  /// 个性签名
  final String signature;

  /// 具体地址
  final String address;

  /// 备注名
  final String noteName;

  /// 备注信息
  final String noteText;

  /// 是否免打扰
  final bool isNoDisturb;

  /// 是否在黑名单中
  final bool isInBlackList;

  /// 是否为好友
  final bool isFriend;

  /// 自定义键值对
  final Map<dynamic, dynamic> extras;

  @override
  bool operator ==(dynamic other) {
    return other is JMUserInfo && other.username == username;
  }

  ///
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
}

///群组信息
class JMGroupInfo extends BaseInfo {
  ///
  JMGroupInfo.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'].toString(),
        desc = json['desc'].toString(),
        level = json['level'] as int,
        owner = json['owner'].toString(),
        ownerAppKey = json['ownerAppKey'].toString(),
        maxMemberCount = json['maxMemberCount'] as int,
        isNoDisturb = json['isNoDisturb'] as bool,
        isBlocked = json['isBlocked'] as bool,
        groupType =
            getEnumFromString(JMGroupType.values, json['groupType'].toString()),
        super(JMGroup(json['id'].toString()));

  /// 群组 id
  final String id;

  /// 群组名称
  final String name;

  /// 群组描述
  final String desc;

  /// 群组等级，默认等级 4
  final int level;

  /// 群主的 username
  final String owner;

  /// 群主的 appKey
  final String ownerAppKey;

  /// 最大成员数
  final int maxMemberCount;

  /// 是否免打扰
  final bool isNoDisturb;

  /// 是否屏蔽群消息
  final bool isBlocked;

  /// 群类型
  final JMGroupType groupType;

  @override
  bool operator ==(dynamic other) {
    return other is JMGroupInfo && other.id == id;
  }

  ///
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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

  ///退出群组
  Future<void> exitGroup({required String id}) async {
    return await jMessage.exitGroup(id: id);
  }

  ///更新群信息
  Future<void> updateGroupInfo({
    required String newName,
    String? newDesc,
  }) async {
    return await jMessage.updateGroupInfo(
      id: id,
      newDesc: newDesc,
      newName: newName,
    );
  }
}

///聊天室信息
class JMChatRoomInfo extends BaseInfo {
  ///
  JMChatRoomInfo.fromJson(Map<dynamic, dynamic> json)
      : roomId = json['roomId'].toString(),
        name = json['name'].toString(),
        appKey = json['appKey'].toString(),
        description = json['description'].toString(),
        createTime = json['createTime'] as int,
        maxMemberCount = json['maxMemberCount'] as int,
        memberCount = json['memberCount'] as int,
        super(JMChatRoom(roomId: json['roomId'].toString()));

  /// 聊天室 id
  final String roomId;

  /// 聊天室名称
  final String name;

  /// 聊天室所属应用的 App Key
  final String appKey;

  /// 聊天室描述信息
  final String description;

  /// 创建日期，单位：秒
  final int createTime;

  /// 最大成员数
  final int maxMemberCount;

  /// 当前成员数
  final int memberCount;

  @override
  bool operator ==(dynamic other) {
    return other is JMChatRoomInfo && other.roomId == roomId;
  }

  ///
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'roomId': roomId,
      'name': name,
      'appKey': appKey,
      'description': description,
      'createTime': createTime,
      'maxMemberCount': maxMemberCount,
      'memberCount': memberCount,
    };
  }
}
