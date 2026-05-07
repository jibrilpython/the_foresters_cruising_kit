import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_foresters_cruising_kit/models/project_model.dart';
import 'package:the_foresters_cruising_kit/providers/image_provider.dart';
import 'package:the_foresters_cruising_kit/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<ForestryInstrumentModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'tfck_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => ForestryInstrumentModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    entries.add(
      ForestryInstrumentModel(
        id: _uuid.v4(),
        cruiserIdentifier: p.cruiserIdentifier,
        toolType: p.toolType,
        specificFunction: p.specificFunction,
        manufacturer: p.manufacturer,
        countryOfOrigin: p.countryOfOrigin,
        eraOfProduction: p.eraOfProduction,
        scaleSystem: p.scaleSystem,
        primaryMaterial: p.primaryMaterial,
        operatingPrinciple: p.operatingPrinciple,
        dimensionsAndWeight: p.dimensionsAndWeight,
        conditionGrade: p.conditionGrade,
        timberRegion: p.timberRegion,
        includedAccessories: p.includedAccessories,
        markingsAndStamps: p.markingsAndStamps,
        provenance: p.provenance,
        notes: p.notes,
        photoPath:
            imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
        tags: List<String>.from(p.tags),
        dateAdded: p.dateAdded,
      ),
    );

    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    entries[index] = ForestryInstrumentModel(
      id: existing.id,
      cruiserIdentifier: p.cruiserIdentifier,
      toolType: p.toolType,
      specificFunction: p.specificFunction,
      manufacturer: p.manufacturer,
      countryOfOrigin: p.countryOfOrigin,
      eraOfProduction: p.eraOfProduction,
      scaleSystem: p.scaleSystem,
      primaryMaterial: p.primaryMaterial,
      operatingPrinciple: p.operatingPrinciple,
      dimensionsAndWeight: p.dimensionsAndWeight,
      conditionGrade: p.conditionGrade,
      timberRegion: p.timberRegion,
      includedAccessories: p.includedAccessories,
      markingsAndStamps: p.markingsAndStamps,
      provenance: p.provenance,
      notes: p.notes,
      photoPath:
          imgProv.resultImage.isNotEmpty ? imgProv.resultImage : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.cruiserIdentifier = entry.cruiserIdentifier;
    p.toolType = entry.toolType;
    p.specificFunction = entry.specificFunction;
    p.manufacturer = entry.manufacturer;
    p.countryOfOrigin = entry.countryOfOrigin;
    p.eraOfProduction = entry.eraOfProduction;
    p.scaleSystem = entry.scaleSystem;
    p.primaryMaterial = entry.primaryMaterial;
    p.operatingPrinciple = entry.operatingPrinciple;
    p.dimensionsAndWeight = entry.dimensionsAndWeight;
    p.conditionGrade = entry.conditionGrade;
    p.timberRegion = entry.timberRegion;
    p.includedAccessories = entry.includedAccessories;
    p.markingsAndStamps = entry.markingsAndStamps;
    p.provenance = entry.provenance;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
