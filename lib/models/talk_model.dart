// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                  UserModel                                   ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class Talk {
  Talk({
    required this.id,
    required this.cont,
    required this.creUserId,
    required this.creDtm,
    required this.image,
  });
  late String id;
  late String cont;
  late String creUserId;
  late String creDtm;
  late String image;

  Talk.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    cont = json['cont'] ?? '';
    creUserId = json['cre_user_id'] ?? '';
    creDtm = json['cre_dtm'] ?? '';
    image = json['image'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['cont'] = cont;
    data['creUserId'] = creUserId;
    data['created_at'] = creDtm;
    data['image'] = image;
    return data;
  }
}