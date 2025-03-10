import 'dart:io';

import 'package:flutter/material.dart';
import '../repositories/blog_repository.dart';
import '../models/blog_post.dart';
import 'create_post_screen.dart';


class BlogScreen extends StatefulWidget {
  final int id;

  const BlogScreen({super.key, required this.id});

  @override
  BlogScreenState createState() => BlogScreenState();
}
class BlogScreenState extends State<BlogScreen> {
  BlogPost? _blogPost;
  final BlogRepository blogRepo = BlogRepository();

  @override
  void initState() {
    super.initState();
    _loadBlog(widget.id);
  }

  Future<void> _loadBlog(id) async {
    final blogData = await blogRepo.fetchBlogById(id);
    print(blogData);
    if (blogData != null){
      setState(() {
            _blogPost = blogData;
          });
    }else {
      setState(() {
            _blogPost = null;
          });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Post:')),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: _blogPost != null? Column(
            children: [
              if (_blogPost!.image_path != null && _blogPost!.image_path!.isNotEmpty) 
                    Image.file(File(_blogPost!.image_path!)),
                Text(_blogPost!.title, 
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
                const SizedBox(height: 20),
                Text(_blogPost!.summary, 
                style: const TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.justify,),
                Text(_blogPost!.content),
                
            ]
        ): Text('Not found...')
        
        )
      )
      )
    );
  }
}
