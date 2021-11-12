import 'package:flutter/material.dart';
import 'package:lab2/controllers/app_controller.dart';
import 'package:lab2/models/post.dart';

class SendPost extends StatelessWidget {
  SendPost({Key? key}) : super(key: key);
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  hintText: 'title.......', labelText: 'Post Title'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                  hintText: 'body.......', labelText: 'Post Body'),
            ),
            const SizedBox(
              height: 13,
            ),
            ElevatedButton(
              onPressed: () async {
                var newPost = Post(
                  userId: 2,
                  title: titleController.text,
                  body: bodyController.text,
                  id: 2,
                );
                await AppContrloller.sendPost(body: newPost.toJson());
              },
              child: const Text('Send Post'),
            )
          ],
        ),
      ),
    );
  }
}
