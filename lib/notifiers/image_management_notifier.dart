import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_leafcloud_app/models/image_info.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class ImageManagementNotifier extends ChangeNotifier {
  final ApiService apiService;

  List<ImageInfo> _images = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentSkip = 0;
  final int _limit = 20;

  ImageManagementNotifier({required this.apiService});

  List<ImageInfo> get images => _images;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> fetchImages({bool refresh = false}) async {
    if (refresh) {
      _currentSkip = 0;
      _hasMore = true;
      _images = [];
      _isLoading = true;
    } else {
      if (!_hasMore || _isFetchingMore) return;
      _isFetchingMore = true;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final newImages = await apiService.fetchImages(skip: _currentSkip, limit: _limit);
      
      if (newImages.length < _limit) {
        _hasMore = false;
      }

      _images.addAll(newImages);
      _currentSkip += newImages.length;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(ImageInfo image) async {
    try {
      await apiService.deleteImage(image.filename);
      _images.removeWhere((img) => img.filename == image.filename);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete image: $e';
      notifyListeners();
      rethrow;
    }
  }
}
