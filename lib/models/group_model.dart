class ChatGroup {
  String? id;
  String? name;
  String? image;
  List? members;
  List? adminsId;
  String? createdAt;
  String? lastMessage;
  String? lastMessageTime;

  ChatGroup({
    required this.id,
    required this.name,
    required this.image,
    required this.members,
    required this.adminsId,
    required this.createdAt,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      image: json['image'] ?? "",
      members: json['members'] ?? [],
      adminsId: json['admins_id'] ?? [],
      createdAt: json['created_at'],
      lastMessage: json['last_message'] ?? "",
      lastMessageTime: json['last_message_time'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'members': members,
      'admins_id': adminsId,
      'created_at': createdAt,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
    };
  }
}
