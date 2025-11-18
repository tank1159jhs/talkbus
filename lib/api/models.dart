class DirectRoom {
  final String id;
  final String userAId;
  final String userBId;
  final DateTime createdAt;

  DirectRoom({
    required this.id,
    required this.userAId,
    required this.userBId,
    required this.createdAt,
  });

  factory DirectRoom.fromJson(Map<String, dynamic> json) {
    return DirectRoom(
      id: json['id'],
      userAId: json['userAId'],
      userBId: json['userBId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class DirectMessage {
  final String id;
  final String directRoomId;
  final String senderId;
  final String body;
  final DateTime createdAt;

  DirectMessage({
    required this.id,
    required this.directRoomId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    return DirectMessage(
      id: json['id'],
      directRoomId: json['directRoomId'],
      senderId: json['senderId'],
      body: json['body'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class GroupRoom {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<dynamic>? memberships;

  GroupRoom({
    required this.id,
    required this.title,
    required this.createdAt,
    this.memberships,
  });

  factory GroupRoom.fromJson(Map<String, dynamic> json) {
    return GroupRoom(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      memberships: json['memberships'],
    );
  }
}

class GroupMessage {
  final String id;
  final String groupRoomId;
  final String authorId;
  final String body;
  final DateTime createdAt;
  final Author? author;

  GroupMessage({
    required this.id,
    required this.groupRoomId,
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.author,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'],
      groupRoomId: json['groupRoomId'],
      authorId: json['authorId'],
      body: json['body'],
      createdAt: DateTime.parse(json['createdAt']),
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
    );
  }
}

class Author {
  final String id;
  final String name;

  Author({
    required this.id,
    required this.name,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'] ?? json['nickname'] ?? 'Anonymous',
    );
  }
}

class TalkPost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final String? authorProfileUrl;
  final String? authorGender;

  TalkPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    this.authorProfileUrl,
    this.authorGender,
  });

  factory TalkPost.fromJson(Map<String, dynamic> json) {
    return TalkPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['authorId'],
      createdAt: DateTime.parse(json['createdAt']),
      authorProfileUrl: json['author']?['profileImageUrl'],
      authorGender: json['author']?['gender'],
    );
  }
}

class UserProfile {
  final String nickname;
  final String? profileImageUrl;
  final String? secretImageUrl;
  final String? email;
  final String? gender;
  final int? age;
  final String? theme;

  UserProfile({
    required this.nickname,
    this.profileImageUrl,
    this.secretImageUrl,
    this.email,
    this.gender,
    this.age,
    this.theme,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      secretImageUrl: json['secretImageUrl'],
      email: json['email'],
      gender: json['gender'],
      age: json['age'],
      theme: json['theme'],
    );
  }
}
