// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                  MessageModel                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class Message {
  Message({
    required this.chatRoomId,//
    required this.told,
    required this.type,
    required this.msg,
    required this.read,
    required this.fromId,
    required this.sent,
  });
  late final String chatRoomId;//
  late final String told;
  late final Type type;
  late final String msg;
  late final String read;
  late final String fromId;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    chatRoomId = json['chatRoomId'].toString(); //
    told = json['told'].toString();
    type = json['type'] == 'image' ? Type.image : Type.text;
    msg = json['msg'].toString();
    read = json['read'].toString();
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['chatRoomId'] = chatRoomId; //
    data['told'] = told;
    data['type'] = type.name; // 열거형을 문자열로 변환하여 저장
    data['msg'] = msg;
    data['read'] = read;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum Type{text, image}