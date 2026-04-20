import 'package:flutter/material.dart';
import 'package:flutter_leafcloud_app/models/trash_item_info.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class TrashNotifier extends ChangeNotifier {
  final ApiService apiService;
  final int _pageSize = 20;

  List<TrashItemInfo> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;

  List<TrashItemInfo> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  TrashNotifier({required this.apiService});

  Future<void> fetchTrashItems() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItems = await apiService.getTrashItems(
        skip: _items.length,
        limit: _pageSize,
      );

      _items.addAll(newItems);
      _hasMore = newItems.length == _pageSize;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _items = [];
    _hasMore = true;
    await fetchTrashItems();
  }
}
