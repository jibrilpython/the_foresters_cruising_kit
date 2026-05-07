import 'package:coopering_croze_barrel/models/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<CrozeModel> filteredList(List<CrozeModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.cooperageIdentifier.toLowerCase().contains(query) ||
              item.manufacturer.toLowerCase().contains(query) ||
              item.countryOfManufacture.toLowerCase().contains(query) ||
              item.specialization.toLowerCase().contains(query) ||
              item.provenance.toLowerCase().contains(query) ||
              item.presumedEra.toLowerCase().contains(query) ||
              item.regionalFeatures.toLowerCase().contains(query) ||
              item.bladeShape.toLowerCase().contains(query) ||
              item.crozeType.label.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
