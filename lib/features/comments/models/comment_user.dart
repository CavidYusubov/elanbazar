class CommentUser {
  final int id;
  final String name;
  final String? photoUrl;

  CommentUser({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}