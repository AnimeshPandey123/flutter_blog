import 'dart:io';

import 'package:flutter/material.dart';
import '../repositories/blog_repository.dart';
import '../models/blog_post.dart';
import 'create_post_screen.dart';
import 'update_post_screen.dart';

import 'blog_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BlogHomePage extends StatefulWidget {
  const BlogHomePage({super.key});

  @override
  BlogHomePageState createState() => BlogHomePageState();
}
class BlogHomePageState extends State<BlogHomePage> {
  List<BlogPost> _blogPosts = [];
  final BlogRepository blogRepo = BlogRepository();

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    final blogsData = await blogRepo.fetchBlogs();
    print(blogsData);
    setState(() {
      _blogPosts = blogsData.map((e) => BlogPost.fromMap(e)).toList();
    });
  }

  Future<void> _addNewPost(String title, String summary, String content, String imagePath, bool isFeatured) async {
    await blogRepo.insertBlog(title, content, summary, imagePath, isFeatured: isFeatured);
    _loadBlogs();
  }


  Future<void> _updatePost(int id, String title, String summary, String content, String image_path, bool isFeatured) async {
    BlogPost blog = await blogRepo.fetchBlogById(id);
    blog.update(
      title: title,
      summary: summary,
      content: content,
      image_path: image_path,
      isFeatured: isFeatured,
    );
    await blogRepo.updateBlog(blog);
    _loadBlogs();
  }



  Future<void> _deletePost(int id) async {
    await blogRepo.deleteBlog(id);
    _loadBlogs();
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(onPostCreated: _addNewPost),
      ),
    );
  }

  Future<void> _navigateToBlogUpdate(id) async {

    BlogPost blog = await blogRepo.fetchBlogById(id);
    print(blog);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePostScreen(
          id: id, 
          existingTitle: blog.title, 
          existingSummary: blog.summary,
          existingContent: blog.content, 
          existingImagePath: blog.image_path,
          existingIsFeatured: blog.isFeatured,
          onPostUpdated: _updatePost),
      ),
    );
  }

  void _navigateToBlogDetail(id){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogScreen(id: id)
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Posts')),
      body: _blogPosts.isEmpty
          ? const Center(child: Text('No blog posts yet. Add some!'))
          : ListView.builder(
              itemCount: _blogPosts.length,
              itemBuilder: (context, index) {
                final post = _blogPosts[index];
                return Slidable(
                  key: ValueKey(post.id),
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => ({print(post.isFeatured)}),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        icon: post.isFeatured ? Icons.star : Icons.star_border,
                        label: post.isFeatured ? 'Unfeature' : 'Feature',
                      ),
                      SlidableAction(
                        onPressed: (context) => _navigateToBlogUpdate(post.id),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) => _deletePost(post.id!),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: post.image_path.isNotEmpty
                          ? Container(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  File(post.image_path),
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            )
                          : const Icon(Icons.image, size: 60),
                    title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(post.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () => _navigateToBlogDetail(post.id),
                  ),
                );

                // return ListTile(
                //   title: Text(post.title),
                //   subtitle: Text(post.summary),
                //   onTap: () => _navigateToBlogDetail(post.id), // Navigate to detail screen

                // );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
