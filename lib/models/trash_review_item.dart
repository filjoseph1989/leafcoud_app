class TrashReviewItem {
  final int id;
  final String filename;
  final String reason;
  final bool isViewed;
  final String? imageUrl;
  final int totalCount;
  final int currentIndex;

  TrashReviewItem({
    required this.id,
    required this.filename,
    required this.reason,
    required this.isViewed,
    required this.totalCount,
    required this.currentIndex,
    this.imageUrl,
  });

  factory TrashReviewItem.fromJson(Map<String, dynamic> json) {
    // Check common keys for nested item data, including 'image'
    final itemData = json['image'] ?? json['metadata'] ?? json['item'] ?? json['data'] ?? json;
    
    // Check common keys for the ID
    final id = itemData['id'] ?? itemData['item_id'] ?? itemData['log_id'];
    
    return TrashReviewItem(
      id: (id as num?)?.toInt() ?? 0,
      filename: itemData['filename'] as String? ?? 'Unknown',
      reason: itemData['reason'] as String? ?? 'No reason provided',
      isViewed: itemData['is_viewed'] as bool? ?? false,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      currentIndex: (json['current_index'] as num?)?.toInt() ?? 0,
      imageUrl: itemData['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'reason': reason,
      'is_viewed': isViewed,
      'image_url': imageUrl,
      'total_count': totalCount,
      'current_index': currentIndex,
    };
  }
}
