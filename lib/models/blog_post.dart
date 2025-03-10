class BlogPost {
  final int? id;
  final String title;
  final String content;
  final String image_path;
  final String summary;

  BlogPost({this.id, 
            required this.title, 
            required this.content, 
            required this.image_path, 
            required this.summary
            });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_path': image_path,
      'summary': summary
    };
  }

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      image_path: map['image_path'],
      summary: map['summary'],
    );
  }
}
