import '../database/database_helper.dart';
import '../models/blog_post.dart';

class BlogRepository {

  //Create Blog
  Future<int> insertBlog(String title, String content, String summary, String imagePath, {bool isFeatured = false}) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('blogs', {
      'title': title, 
      'content': content, 
      'summary': summary, 
      'image_path': imagePath,
      'is_featured': isFeatured ? 1 : 0
    });
  }

  //Fetch all blogs
  Future<List<Map<String, dynamic>>> fetchBlogs() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('blogs');
  }
  
  //Fetch featured blogs
  Future<List<Map<String, dynamic>>> fetchFeaturedBlogs() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'blogs',
      where: 'is_featured = ?',
      whereArgs: [1],
    );
  }

  // Fetch a single blog by ID
  Future<BlogPost> fetchBlogById(int id) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'blogs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BlogPost.fromMap(maps.first);
    } else {
      throw Exception("Blog not found.");
    }
  }

  // Update an existing blog
  Future<int> updateBlog(BlogPost blog) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'blogs',
      blog.toMap(),
      where: 'id = ?',
      whereArgs: [blog.id],
    );
  }

  // Search the blog
  Future<List<Map<String, dynamic>>> searchBlogs(String query) async {
    final db = await DatabaseHelper.instance.database;

    return await db.query(
      'blogs',
      where: 'title LIKE ? OR content LIKE ? OR summary LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  // Toggle featured status
  Future<int> toggleFeatured(int id, bool isFeatured) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'blogs',
      {'is_featured': isFeatured ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a blog by ID
  Future<int> deleteBlog(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'blogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}