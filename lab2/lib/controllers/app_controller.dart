import 'dart:convert';

import 'package:lab2/models/comment.dart';
import 'package:lab2/models/post.dart';
import 'package:http/http.dart' as http;

class AppContrloller {
  static Future<List<Post>> getPosts() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    return List<Post>.from(
        jsonDecode(response.body).map((e) => Post.fromJson(e)));
  }

  static Future<List<Comment>> getcomments(int postid) async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/comments?postId=$postid'));

    return List<Comment>.from(
        jsonDecode(response.body).map((com) => Comment.fromJson(com)));
  }
  static Future sendPost({required Map<String, dynamic> body}) async {
    String url = 'https://jsonplaceholder.typicode.com/posts';

    return http.post(Uri.parse(url),
        body: jsonEncode(body),
        headers: {"Content-type": "application/json"}).then((value) {
      final statusCode = value.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        throw Exception('Error Featch Data..........');
      }

      print(statusCode);
    });
  }
}
