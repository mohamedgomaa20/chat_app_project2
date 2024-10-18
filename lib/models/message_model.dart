class Message {
  String? id;
  String? msg;
  String? fromId;
  String? toId;
  String? createdAt;
  String? read;
  String? type;

  Message({
    required this.id,
    required this.msg,
    required this.fromId,
    required this.toId,
    required this.createdAt,
    required this.read,
    required this.type,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      msg: json['message'],
      fromId: json['from_id'],
      toId: json['to_id'],
      createdAt: json['created_at'],
      read: json['read'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': msg,
      'from_id': fromId,
      'to_id': toId,
      'created_at': createdAt,
      'read': read,
      'type': type,
    };
  }
}
