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
  List<BlogPost> _featuredPosts = [];
  List<BlogPost> _searchResults = []; 
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController(); 

  final BlogRepository blogRepo = BlogRepository();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller when widget is disposed
    super.dispose();
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

  // New method to handle search
  Future<void> _searchBlogs(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }
    
    final searchData = await blogRepo.searchBlogs(query);
    
    setState(() {
      _isSearching = true;
      _searchResults = searchData.map((e) => BlogPost.fromMap(e)).toList();
    });
  }

  // Method to clear search and return to normal view
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  void showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addNewPost(String title, String summary, String content, String imagePath, bool isFeatured) async {
    await blogRepo.insertBlog(title, content, summary, imagePath, isFeatured: isFeatured);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New post added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );

    showSnackBar('New post added successfully!');
    _initializePage();
  }

  Future<void> _updatePost(int id, String title, String summary, String content, String imagePath, bool isFeatured) async {
    BlogPost blog = await blogRepo.fetchBlogById(id);
    blog.update(
      title: title,
      summary: summary,
      content: content,
      image_path: imagePath,
      isFeatured: isFeatured,
    );
    await blogRepo.updateBlog(blog);

    showSnackBar('The post was updated successfully!');

    _initializePage();
  }

  Future<void> _deletePost(int id) async {
    await blogRepo.deleteBlog(id);
    showSnackBar('The post was deleted successfully!');

    _initializePage();
  }

  // New method to show confirmation dialog before deletion
  Future<void> _confirmDeletePost(BuildContext context, int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _deletePost(id); // Delete the post
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(onPostCreated: _addNewPost),
      ),
    );
  }

  Future<void> _toggleFeaturedBlog(int id) async {
  try {
    final blog = await blogRepo.fetchBlogById(id);
    final updated = await blogRepo.toggleFeatured(id, !blog.isFeatured);

    if (updated > 0) {
      showSnackBar('The post was ${!blog.isFeatured ? 'featured' : 'unfeatured'} successfully!');
      _initializePage();
    } else {
      showSnackBar('Failed to update the post.');
    }
  } catch (e) {
    showSnackBar('An error occurred: $e');
  }
}


  Future<void> _navigateToBlogUpdate(id) async {
    BlogPost blog = await blogRepo.fetchBlogById(id);
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs by title or content...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchBlogs,
            ),
          ),
          
          // Main content - Expanded to fill available space
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildNormalView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget for showing search results
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No matching blogs found'));
    }
    
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return Slidable(
          key: ValueKey(post.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => _navigateToBlogUpdate(post.id),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (context) => _confirmDeletePost(context, post.id!),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            leading: post.image_path.isNotEmpty
                ? SizedBox(
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
    );
  }

  Widget _buildNormalView() {
    if (_blogPosts.isEmpty && _featuredPosts.isEmpty) {
      return const Center(child: Text('No blog posts yet. Add some!'));
    }
    
    return SingleChildScrollView(
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
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'All blogs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _blogPosts.length,
            itemBuilder: (context, index) {
              final post = _blogPosts[index];
              return Slidable(
                key: ValueKey(post.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _toggleFeaturedBlog(post.id!),
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
                      onPressed: (context) => _confirmDeletePost(context, post.id!),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: post.image_path.isNotEmpty
                      ? SizedBox(
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
    );
  }
}