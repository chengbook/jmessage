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
}
