class ImageInfo {
  final int? id;
  final String filename;
  final int? readingId;
  final DateTime? timestamp;
  final String? bucketLabel;
  final String imageUrl;
  final bool isOrphaned;

  ImageInfo({
    this.id,
    required this.filename,
    this.readingId,
    this.timestamp,
    this.bucketLabel,
    required this.imageUrl,
    this.isOrphaned = false,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      id: json['id'] as int?,
      filename: json['filename'] as String,
      readingId: json['reading_id'] as int?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'].toString()) 
          : null,
      bucketLabel: json['bucket_label'] as String?,
      imageUrl: json['image_url'] as String,
      isOrphaned: json['is_orphaned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'reading_id': readingId,
      'timestamp': timestamp?.toIso8601String(),
      'bucket_label': bucketLabel,
      'image_url': imageUrl,
      'is_orphaned': isOrphaned,
    };
  }
}
