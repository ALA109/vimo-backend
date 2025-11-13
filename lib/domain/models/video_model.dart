class Video {
  final String id;
  final String userId;
  final String url;
  final String? caption;
  final String? songName;
  int likes;
  int comments;
  int shares;
  bool isLiked;

  Video({
    required this.id,
    required this.userId,
    required this.url,
    this.caption,
    this.songName,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      // يقبل أيًا من الحقول: url أو video_url
      url: (map['url'] ?? map['video_url'] ?? '') as String,
      // الوصف/العنوان حسب المخطط المتوفر
      caption: (map['description'] ?? map['caption'] ?? '') as String,
      songName: (map['title'] ?? map['song_name'] ?? '') as String,
      likes: (map['likes_count'] ?? map['likes'] ?? 0) as int,
      comments: (map['comments_count'] ?? map['comments'] ?? 0) as int,
      shares: (map['shares_count'] ?? map['shares'] ?? 0) as int,
      isLiked: (map['is_liked'] ?? false) as bool,
    );
  }
}
