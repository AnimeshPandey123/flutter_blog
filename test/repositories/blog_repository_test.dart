import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:project_work/database/database_helper.dart';
import 'package:project_work/models/blog_post.dart';
import 'package:project_work/repositories/blog_repository.dart';

// Import the generated mocks file - will be created after running build_runner
import 'blog_repository_test.mocks.dart';

// Mock Database without annotations
class MockDatabase extends Mock implements Database {}

// Generate mocks for DatabaseHelper
@GenerateMocks([DatabaseHelper])
void main() {
  // Initialize FFI for in-memory database
  sqfliteFfiInit();

  late BlogRepository blogRepository;
  late MockDatabaseHelper mockDatabaseHelper;
  late Database db;

  setUp(() async {
    // Create a mock DatabaseHelper
    mockDatabaseHelper = MockDatabaseHelper();
    
    // Create an in-memory database for testing
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    
    // Create the blogs table with the exact same schema as in your DatabaseHelper
    await db.execute('''
      CREATE TABLE blogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        image_path TEXT NULL,
        summary TEXT NULL,
        is_featured INTEGER DEFAULT 0
      )
    ''');
    
    // Mock the database getter to return our in-memory database
    when(mockDatabaseHelper.database).thenAnswer((_) async => db);
    
    // Use our mocked DatabaseHelper
    // NOTE: This requires DatabaseHelper to have a settable instance property
    // You might need to modify your DatabaseHelper class to support this
    DatabaseHelper.setInstance(mockDatabaseHelper);
    
    // Initialize the repository
    blogRepository = BlogRepository();
  });

  tearDown(() async {
    // Close the database after each test
    await db.close();
  });

  group('BlogRepository', () {
    test('insertBlog should insert a blog and return an id', () async {
      // Act
      final id = await blogRepository.insertBlog(
        'Test Title', 
        'Test Content', 
        'Test Summary', 
        'test_image.jpg',
        isFeatured: true
      );
      
      // Assert
      expect(id, 1); // First inserted item should have id 1
      
      // Verify that the blog was actually inserted
      final blogs = await db.query('blogs');
      expect(blogs.length, 1);
      expect(blogs.first['title'], 'Test Title');
      expect(blogs.first['is_featured'], 1);
    });

    test('fetchBlogs should return all blogs', () async {
      // Arrange - Insert test data
      await db.insert('blogs', {
        'title': 'Blog 1',
        'content': 'Content 1',
        'summary': 'Summary 1',
        'image_path': 'image1.jpg',
        'is_featured': 0
      });
      await db.insert('blogs', {
        'title': 'Blog 2',
        'content': 'Content 2',
        'summary': 'Summary 2',
        'image_path': 'image2.jpg',
        'is_featured': 1
      });
      
      // Act
      final blogs = await blogRepository.fetchBlogs();
      
      // Assert
      expect(blogs.length, 2);
      expect(blogs[0]['title'], 'Blog 1');
      expect(blogs[1]['title'], 'Blog 2');
    });

    test('fetchFeaturedBlogs should return only featured blogs', () async {
      // Arrange
      await db.insert('blogs', {
        'title': 'Blog 1',
        'content': 'Content 1',
        'summary': 'Summary 1',
        'image_path': 'image1.jpg',
        'is_featured': 0
      });
      await db.insert('blogs', {
        'title': 'Blog 2',
        'content': 'Content 2',
        'summary': 'Summary 2',
        'image_path': 'image2.jpg',
        'is_featured': 1
      });
      await db.insert('blogs', {
        'title': 'Blog 3',
        'content': 'Content 3',
        'summary': 'Summary 3',
        'image_path': 'image3.jpg',
        'is_featured': 1
      });
      
      // Act
      final featuredBlogs = await blogRepository.fetchFeaturedBlogs();
      
      // Assert
      expect(featuredBlogs.length, 2);
      expect(featuredBlogs[0]['title'], 'Blog 2');
      expect(featuredBlogs[1]['title'], 'Blog 3');
    });

    test('fetchBlogById should return the correct blog', () async {
      // Arrange
      await db.insert('blogs', {
        'title': 'Blog 1',
        'content': 'Content 1',
        'summary': 'Summary 1',
        'image_path': 'image1.jpg',
        'is_featured': 0
      });
      await db.insert('blogs', {
        'title': 'Blog 2',
        'content': 'Content 2',
        'summary': 'Summary 2',
        'image_path': 'image2.jpg',
        'is_featured': 1
      });
      
      // Act
      final blog = await blogRepository.fetchBlogById(2);
      
      // Assert
      expect(blog.id, 2);
      expect(blog.title, 'Blog 2');
      expect(blog.content, 'Content 2');
      expect(blog.isFeatured, true);
    });

    test('fetchBlogById should throw exception when blog not found', () async {
      // Assert
      expect(() => blogRepository.fetchBlogById(999), throwsException);
    });

    test('updateBlog should update the blog and return count of updated rows', () async {
      // Arrange
      await db.insert('blogs', {
        'title': 'Original Title',
        'content': 'Original Content',
        'summary': 'Original Summary',
        'image_path': 'original.jpg',
        'is_featured': 0
      });
      
      final updatedBlog = BlogPost(
        id: 1,
        title: 'Updated Title',
        content: 'Updated Content',
        image_path: 'updated.jpg',  // Fixed parameter name to match model
        summary: 'Updated Summary',
        isFeatured: true
      );
      
      // Act
      final updatedRows = await blogRepository.updateBlog(updatedBlog);
      
      // Assert
      expect(updatedRows, 1);
      
      final blogs = await db.query('blogs', where: 'id = ?', whereArgs: [1]);
      expect(blogs.length, 1);
      expect(blogs.first['title'], 'Updated Title');
      expect(blogs.first['content'], 'Updated Content');
      expect(blogs.first['is_featured'], 1);
    });

    test('searchBlogs should return blogs matching the query', () async {
      // Arrange
      await db.insert('blogs', {
        'title': 'Flutter Tutorial',
        'content': 'Learn about Flutter',
        'summary': 'A guide to Flutter',
        'image_path': 'flutter.jpg',
        'is_featured': 0
      });
      await db.insert('blogs', {
        'title': 'Dart Basics',
        'content': 'Introduction to Dart',
        'summary': 'Learn Dart programming',
        'image_path': 'dart.jpg',
        'is_featured': 1
      });
      await db.insert('blogs', {
        'title': 'Advanced Flutter',
        'content': 'State management in Flutter',
        'summary': 'Flutter state management',
        'image_path': 'state.jpg',
        'is_featured': 0
      });
      
      // Act
      final results = await blogRepository.searchBlogs('Flutter');
      
      // Assert
      expect(results.length, 2);
      expect(results.any((blog) => blog['title'] == 'Flutter Tutorial'), true);
      expect(results.any((blog) => blog['title'] == 'Advanced Flutter'), true);
    });

    test('toggleFeatured should update the featured status', () async {
      // Arrange
      await db.insert('blogs', {
        'title': 'Blog Post',
        'content': 'Content',
        'summary': 'Summary',
        'image_path': 'image.jpg',
        'is_featured': 0
      });
      
      // Act
      final updatedRows = await blogRepository.toggleFeatured(1, true);
      
      // Assert
      expect(updatedRows, 1);
      
      final blogs = await db.query('blogs', where: 'id = ?', whereArgs: [1]);
      expect(blogs.first['is_featured'], 1);
      
      // Toggle back to false
      final updatedAgain = await blogRepository.toggleFeatured(1, false);
      expect(updatedAgain, 1);
      
      final blogsAgain = await db.query('blogs', where: 'id = ?', whereArgs: [1]);
      expect(blogsAgain.first['is_featured'], 0);
    });

    test('deleteBlog should remove the blog and return count of deleted rows', () async {
      // Arrange
      await db.insert('blogs', {
        'title': 'Blog to Delete',
        'content': 'Will be deleted',
        'summary': 'Soon deleted',
        'image_path': 'delete.jpg',
        'is_featured': 0
      });
      
      // Verify it was inserted
      var blogs = await db.query('blogs');
      expect(blogs.length, 1);
      
      // Act
      final deletedRows = await blogRepository.deleteBlog(1);
      
      // Assert
      expect(deletedRows, 1);
      
      blogs = await db.query('blogs');
      expect(blogs.length, 0);
    });
  });
}