import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_leafcloud_app/models/image_info.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class ImageManagementNotifier extends ChangeNotifier {
  final ApiService apiService;
  
  List<ImageInfo> _images = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 50;

  List<ImageInfo> get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  ImageManagementNotifier({required this.apiService});

  Future<void> fetchImages({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 0;
      _images = [];
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newImages = await apiService.fetchImages(
        skip: _currentPage * _pageSize,
        limit: _pageSize,
      );
      
      _images.addAll(newImages);
      _hasMore = newImages.length == _pageSize;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(ImageInfo image) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Prioritize Log ID, fallback to readingId or 0 if necessary
      final int idToDelete = image.id ?? image.readingId ?? 0;
      await apiService.deleteImage(image.filename, id: idToDelete);
      _images.removeWhere((img) => img.filename == image.filename);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
