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
  List<BlogPost> _featuredPosts = []; // <- ✅ Add this line

  final BlogRepository blogRepo = BlogRepository();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    _loadBlogs();
    _loadFeaturedBlogs();
  }

  Future<void> _loadBlogs() async {
    final blogsData = await blogRepo.fetchBlogs();
    print(blogsData);
    setState(() {
      _blogPosts = blogsData.map((e) => BlogPost.fromMap(e)).toList();
    });
  }
  Future<void> _loadFeaturedBlogs() async {
    final featuredData = await blogRepo.fetchFeaturedBlogs();

    setState(() {
      _featuredPosts = featuredData.map((e) => BlogPost.fromMap(e)).toList();

    });
  }

  Future<void> _addNewPost(String title, String summary, String content, String imagePath, bool isFeatured) async {
    await blogRepo.insertBlog(title, content, summary, imagePath, isFeatured: isFeatured);
    _initializePage();
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
    _initializePage();
  }



  Future<void> _deletePost(int id) async {
    await blogRepo.deleteBlog(id);
    _initializePage();
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
      body: _blogPosts.isEmpty && _featuredPosts.isEmpty
    ? const Center(child: Text('No blog posts yet. Add some!'))
    : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_featuredPosts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Featured Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _featuredPosts.length,
                  itemBuilder: (context, index) {
                    final featured = _featuredPosts[index];
                    return GestureDetector(
                      onTap: () => _navigateToBlogDetail(featured.id),
                      child: Container(
                        width: 280,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              featured.image_path.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                      child: Image.file(
                                        File(featured.image_path),
                                        width: 280,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 280,
                                      height: 120,
                                      child: Icon(Icons.image, size: 60),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  featured.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  featured.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
