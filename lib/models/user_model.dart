class ChatUser {
  String? id;
  String? name;
  String? email;
  String? about;
  String? image;
  bool? online;
  String? pushToken;
  String? lastActivated;
  String? createdAt;
  List? myContacts;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.about,
    required this.image,
    required this.online,
    required this.pushToken,
    required this.lastActivated,
    required this.createdAt,
    required this.myContacts,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? "",
      name: json['name'],
      email: json['email'],
      about: json['about'],
      image: json['image'],
      online: json['online'],
      pushToken: json['push_token'],
      lastActivated: json['last_activated'],
      createdAt: json['created_at'],
      myContacts: json['my_contacts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'about': about,
      'image': image,
      'online': online,
      'push_token': pushToken,
      'last_activated': lastActivated,
      'created_at': createdAt,
      'my_contacts': myContacts,
    };
  }
}
