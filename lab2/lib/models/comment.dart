class Comment {
  final int? postId;
  final int? id;
  final String? name;
  final String? body;
  Comment(
      {required this.postId,
      required this.id,
      required this.name,
      required this.body});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        postId: json['postId'],
        id: json['id'],
        name: json['name'],
        body: json['body']);
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['postId'] = postId;
    map['id'] = id;
    map['name'] = name;
    map['body'] = body;
    return map;
  }
}
