import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/blog_repository.dart';
import '../models/blog_post.dart';
import 'package:share_plus/share_plus.dart';

class BlogScreen extends StatefulWidget {
  final int id;
  
  const BlogScreen({super.key, required this.id});
  
  @override
  BlogScreenState createState() => BlogScreenState();
}

class BlogScreenState extends State<BlogScreen> {
  BlogPost? _blogPost;
  final BlogRepository blogRepo = BlogRepository();
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _loadBlog(widget.id);
  }
  
  Future<void> _loadBlog(int id) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final blogData = await blogRepo.fetchBlogById(id);
      setState(() {
        _blogPost = blogData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showErrorSnackBar('Failed to load blog post');
    }
  }
  
  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Opens dialoge to share post
  void _sharePost() async {
    if (_blogPost == null) return;
    
    final String text = 'Check out this blog post: ${_blogPost!.title}\n\n${_blogPost!.summary}';
    
    try {
      if (_blogPost!.image_path.isNotEmpty) {
        // Share with image
        final xFile = XFile(_blogPost!.image_path);
        await Share.shareXFiles(
          [xFile],
          text: text,
          subject: _blogPost!.title,
        );
      } else {
        // Share text only
        await Share.share(
          text,
          subject: _blogPost!.title,
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sharing post...'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share post');
    }
  }
  
  // Open dialoge to share image
  void _shareImage() async {
    if (_blogPost == null || _blogPost!.image_path.isEmpty) return;
    
    try {
      final xFile = XFile(_blogPost!.image_path);
      await Share.shareXFiles(
        [xFile],
        text: 'Image from blog: ${_blogPost!.title}',
        subject: 'Blog image',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sharing image...'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share image');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(
          _blogPost?.title ?? 'Blog Post',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_blogPost != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadBlog(widget.id),
              tooltip: 'Refresh',
            ),
          if (_blogPost != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePost,
              tooltip: 'Share Post',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load blog post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadBlog(widget.id),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_blogPost == null) {
      return const Center(
        child: Text('Blog post not found'),
      );
    }
    
    return _buildBlogContent();
  }
  
  Widget _buildBlogContent() {
    return CustomScrollView(
      slivers: [
        if (_blogPost!.image_path.isNotEmpty)
          SliverToBoxAdapter(
            child: Hero(
              tag: 'blog_image_${_blogPost!.id}',
              child: Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: Image.file(
                      File(_blogPost!.image_path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Add share button overlay for image
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        tooltip: 'Share Image',
                        onPressed: _shareImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_blogPost!.image_path.isEmpty)
                  const SizedBox(height: 16),
                Text(
                  _blogPost!.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _blogPost!.summary,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildContentSection(),
                const SizedBox(height: 40),
                // _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _blogPost!.content,
          style: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}