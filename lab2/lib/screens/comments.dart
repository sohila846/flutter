import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lab2/models/comment.dart';
import 'package:lab2/models/post.dart';
import 'package:lab2/controllers/app_controller.dart';
import 'package:http/http.dart' as http;
class RecipeDetail extends StatefulWidget {
  final int id;
  
  const RecipeDetail(this.id, {Key? key}) : super(key: key);

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
 List<Comment> comments=[];
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      var comData = await AppContrloller.getcomments(widget.id);
      setState(() {
        comments = comData;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
       appBar: AppBar(
        title: Text("comments for post "+widget.id.toString()),
        
      ),
      
      body: comments.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                   
                    title: Text(comments[index].name.toString()),
                    subtitle: Text(comments[index].body.toString()),
                  );
                }));
        
  }
}





