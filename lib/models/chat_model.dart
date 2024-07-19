// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                  ChatRoomModel                                   ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class ChatRoom {
  ChatRoom({
    required this.chatRoomId,
    required this.member,
    required this.lastMsgDtm,
  });
  late final String chatRoomId;
  late final List<String> member;
  late final String lastMsgDtm;

  ChatRoom.fromJson(Map<String, dynamic> json) {
    chatRoomId = json['chat_room_id'].toString();
    member = json['member'] != null ? List<String>.from(json['member']) : []; // 리스트 초기화
    lastMsgDtm = json['last_msg_dtm'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['chat_room_id'] = chatRoomId;
    data['member'] = member; // 리스트를 그대로 저장
    data['last_msg_dtm'] = lastMsgDtm;
    return data;
  }
}