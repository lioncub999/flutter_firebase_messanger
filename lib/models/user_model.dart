// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                  UserModel                                   ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class ModuUser {
  ModuUser({
    required this.image,
    required this.gender,
    required this.birthDay,
    required this.theme,
    required this.emotionMsg,
    required this.introduce,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.isDefaultInfoSetting,
    required this.pushToken,
  });
  late String image;
  late String gender;
  late String birthDay;
  late String theme;
  late String emotionMsg;
  late String introduce;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late bool isDefaultInfoSetting;
  late String pushToken;

  ModuUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    gender = json['gender'] ?? '';
    birthDay = json['birthDay'] ?? '';
    theme = json['theme'] ?? '';
    emotionMsg = json['emotionMsg'] ?? '';
    introduce = json['introduce'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    isDefaultInfoSetting = json['isDefaultInfoSetting'] ?? false;
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
     data['gender'] = gender;
     data['birthDay'] = birthDay;
     data['theme'] = theme;
     data['emotionMsg'] = emotionMsg;
     data['introduce'] = introduce;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['isDefaultInfoSetting'] = isDefaultInfoSetting;
    data['push_token'] = pushToken;
    return data;
  }
}