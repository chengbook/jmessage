import 'package:jmessage_flutter/jmessage_flutter.dart';

///消息类型
enum JMMessageType {
  ///文本消息
  text,

  ///图片消息
  image,

  ///语音消息
  voice,

  ///文件消息
  file,

  ///自定义消息
  custom,

  ///定位消息
  location,

  ///事件
  event,

  ///
  prompt
}

///消息状态
enum JMMessageState {
  /// 创建的消息，还未发送
  draft,

  /// 正在发送中
  sending,

  /// 发送成功
  send_succeed,

  /// 接收中的消息，一般在 SDK 内部使用，无需考虑
  receiving,

  /// 已经成功接收
  received,

  /// 发送失败
  send_failed,

  /// 上传成功
  upload_succeed,

  /// 上传失败
  upload_failed,

  /// 接收消息时自动下载资源失败
  download_failed
}

///事件类型
enum JMEventType {
  ///添加群成员事件
  group_member_added,

  ///移除群成员
  group_member_removed,

  ///群成员退出
  group_member_exit,

  ///管理员添加
  group_keeper_added,

  ///移除管理员
  group_keeper_removed,

  ///群解散
  group_dissolved
}

///基础消息类
abstract class JMNormalMessage {
  ///解析json
  JMNormalMessage.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'] as String,
        createTime = json['createTime'] as int,
        serverMessageId = json['serverMessageId'] as String,
        isSend = json['isSend'] as bool,
        state =
            getEnumFromString(JMMessageState.values, json['state'].toString()),
        from = JMUserInfo.fromJson(json['from'] as Map<String, dynamic>),
        extras = json['extras'] is Map<dynamic, dynamic>
            ? json['extras'] as Map<String, dynamic>
            : null {
    switch (json['target']['type']) {
      case 'user':
        target = JMUserInfo.fromJson(json['target'] as Map<String, dynamic>);
        break;
      case 'group':
        target = JMGroupInfo.fromJson(json['target'] as Map<String, dynamic>);
        break;
    }
  }

  ///工厂方法
  factory JMNormalMessage.cast(Map<String, dynamic> json) {
    final JMMessageType type =
        getEnumFromString(JMMessageType.values, json['type'].toString());
    switch (type) {
      case JMMessageType.text:
        return JMTextMessage.fromJson(json);
      case JMMessageType.image:
        return JMImageMessage.fromJson(json);
      case JMMessageType.voice:
        return JMVoiceMessage.fromJson(json);
      case JMMessageType.location:
        return JMLocationMessage.fromJson(json);
      case JMMessageType.file:
        return JMFileMessage.fromJson(json);
      case JMMessageType.custom:
        return JMCustomMessage.fromJson(json);
      case JMMessageType.event:
        return JMEventMessage.fromJson(json);
      case JMMessageType.prompt:
        return JMPromptMessage.fromJson(json);
    }
  }

  //// 本地数据库中的消息 id
  final String id;

  /// 消息的状态
  final JMMessageState state;

  /// 对应服务器端的消息 id，只用于在服务端查询问题
  final String serverMessageId;

  /// 消息是否由当前用户发出。true：为当前用户发送；false：为对方用户发送。
  final bool isSend;

  /// 消息发送者对象
  final JMUserInfo from;

  /// 发送消息时间
  final int createTime;

  /// 附带的键值对
  final Map<String, dynamic>? extras;

  /// JMUserInfo | JMGroupInfo
  late final dynamic target;

  ///转为json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'serverMessageId': serverMessageId,
      'isSend': isSend,
      'from': from.toJson(),
      'createTime': createTime,
      'extras': extras,
      'target': target.toJson()
    };
  }
}

///文本消息
class JMTextMessage extends JMNormalMessage {
  ///
  JMTextMessage.fromJson(Map<String, dynamic> json)
      : text = json['text'].toString(),
        super.fromJson(json);

  ///文字消息
  final JMMessageType type = JMMessageType.text;

  ///内容
  final String text;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['type'] = getStringFromEnum(JMMessageType.text);
    json['text'] = text;
    return json;
  }
}

///语音消息
class JMVoiceMessage extends JMNormalMessage {
  ///解析json
  JMVoiceMessage.fromJson(Map<dynamic, dynamic> json)
      : path = json['path'].toString(),
        duration = json['duration'] as int,
        super.fromJson(json);

  /// 语音文件路径,如果为空需要调用相应下载方法，注意这是本地路径，不能是 url
  final String path;

  /// 语音时长，单位秒
  final int duration;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['path'] = path;
    json['duration'] = duration;
    return json;
  }
}

///图片消息
class JMImageMessage extends JMNormalMessage {
  /// 图片的缩略图路径, 如果为空需要调用相应下载方法
  final String thumbPath;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['thumbPath'] = thumbPath;
    return json;
  }

  ///
  JMImageMessage.fromJson(Map<dynamic, dynamic> json)
      : thumbPath = json['thumbPath'].toString(),
        super.fromJson(json);
}

///
class JMFileMessage extends JMNormalMessage {
  ///文件名
  final String fileName;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['fileName'] = fileName;
    return json;
  }

  ///
  JMFileMessage.fromJson(Map<dynamic, dynamic> json)
      : fileName = json['fileName'].toString(),
        super.fromJson(json);
}

///位置
class JMLocationMessage extends JMNormalMessage {
  /// 经度
  final double longitude;

  /// 纬度
  final double latitude;

  /// 地图缩放比例
  final int scale;

  /// 详细地址
  final String address;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['longitude'] = longitude;
    json['latitude'] = latitude;
    json['scale'] = scale;
    json['address'] = address;

    return json;
  }

  ///
  JMLocationMessage.fromJson(Map<dynamic, dynamic> json)
      : longitude = json['longitude'] as double,
        latitude = json['latitude'] as double,
        scale = json['scale'] as int,
        address = json['address'].toString(),
        super.fromJson(json);
}

///自定义消息
class JMCustomMessage extends JMNormalMessage {
  /// 自定义键值对
  final Map<String, dynamic> customObject;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['customObject'] = customObject;
    return json;
  }

  ///
  JMCustomMessage.fromJson(Map<String, dynamic> json)
      : customObject = json['customObject'] as Map<String, dynamic>,
        super.fromJson(json);
}

///提示消息
class JMPromptMessage extends JMNormalMessage {
  ///提示文字
  final String promptText;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json["promptText"] = promptText;
    return json;
  }

  ///
  JMPromptMessage.fromJson(Map<dynamic, dynamic> json)
      : promptText = json["promptText"].toString(),
        super.fromJson(json);
}

///事件消息
class JMEventMessage extends JMNormalMessage {
  ///事件类型
  final JMEventType eventType;

  ///成员列表
  final List<String> usernames;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['eventType'] = getStringFromEnum(eventType);
    json['usernames'] = usernames;
    return json;
  }

  ///
  JMEventMessage.fromJson(Map<dynamic, dynamic> json)
      : eventType =
            getEnumFromString(JMEventType.values, json['eventType'].toString()),
        usernames = (json['usernames'] as List<dynamic>)
            .map((dynamic e) => e.toString())
            .toList(),
        super.fromJson(json);
}
