class BlogPost {
   int? id;
   String title;
   String content;
   String image_path;
   String summary;
   bool isFeatured;

  BlogPost({
    this.id, 
    required this.title, 
    required this.content, 
    required this.image_path, 
    required this.summary,
    this.isFeatured = false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_path': image_path,
      'summary': summary,
      'is_featured': isFeatured ? 1 : 0
    };
  }

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      image_path: map['image_path'] ?? '',
      summary: map['summary'] ?? '',
      isFeatured: map['is_featured'] == 1,
    );
  }

  void update({String? title, String? summary, String? content, String? image_path, bool? isFeatured}) {
    if (title != null) this.title = title;
    if (summary != null) this.summary = summary;
    if (content != null) this.content = content;
    if (image_path != null) this.image_path = image_path;
    if (isFeatured != null) this.isFeatured = isFeatured;
  }
}