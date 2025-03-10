import 'package:flutter/material.dart';
import '../repositories/blog_repository.dart';
import '../models/blog_post.dart';
import 'create_post_screen.dart';
import 'blog_screen.dart';

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

  Future<void> _addNewPost(String title, String summary, String content, String image_path) async {
    await blogRepo.insertBlog(title, content, summary, image_path);
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
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(post.summary),
                  onTap: () => _navigateToBlogDetail(post.id), // Navigate to detail screen

                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
