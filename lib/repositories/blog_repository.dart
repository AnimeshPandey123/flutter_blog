import '../database/database_helper.dart';
import '../models/blog_post.dart';

class BlogRepository {

  //Create Blog
  Future<int> insertBlog(String title, String content,String summary, String imagePath  ) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('blogs', {'title': title, 'content': content, 'summary': summary, 'image_path': imagePath});
  }

  //Fetch all blogs
  Future<List<Map<String, dynamic>>> fetchBlogs() async {
    final db = await DatabaseHelper.instance.database;

    return await db.query('blogs');
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
    }else {
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