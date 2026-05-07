import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:coopering_croze_barrel/models/project_model.dart';
import 'package:coopering_croze_barrel/providers/image_provider.dart';
import 'package:coopering_croze_barrel/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<CrozeModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0; // Increment on every modification to sync UI
  static const String _storageKey = 'ccb_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => CrozeModel.fromJson(item))
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
      CrozeModel(
        id: _uuid.v4(),
        cooperageIdentifier: p.cooperageIdentifier,
        crozeType: p.crozeType,
        barrelType: p.barrelType,
        specialization: p.specialization,
        barrelVolume: p.barrelVolume,
        manufacturer: p.manufacturer,
        countryOfManufacture: p.countryOfManufacture,
        presumedEra: p.presumedEra,
        manufacturingMaterial: p.manufacturingMaterial,
        grooveWidth: p.grooveWidth,
        grooveDepth: p.grooveDepth,
        adjustments: p.adjustments,
        bladeShape: p.bladeShape,
        conditionState: p.conditionState,
        stampsAndMarkings: p.stampsAndMarkings,
        regionalFeatures: p.regionalFeatures,
        provenance: p.provenance,
        notes: p.notes,
        photoPath: imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
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

    entries[index] = CrozeModel(
      id: existing.id,
      cooperageIdentifier: p.cooperageIdentifier,
      crozeType: p.crozeType,
      barrelType: p.barrelType,
      specialization: p.specialization,
      barrelVolume: p.barrelVolume,
      manufacturer: p.manufacturer,
      countryOfManufacture: p.countryOfManufacture,
      presumedEra: p.presumedEra,
      manufacturingMaterial: p.manufacturingMaterial,
      grooveWidth: p.grooveWidth,
      grooveDepth: p.grooveDepth,
      adjustments: p.adjustments,
      bladeShape: p.bladeShape,
      conditionState: p.conditionState,
      stampsAndMarkings: p.stampsAndMarkings,
      regionalFeatures: p.regionalFeatures,
      provenance: p.provenance,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty ? imgProv.resultImage : existing.photoPath,
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

    p.cooperageIdentifier = entry.cooperageIdentifier;
    p.crozeType = entry.crozeType;
    p.barrelType = entry.barrelType;
    p.specialization = entry.specialization;
    p.barrelVolume = entry.barrelVolume;
    p.manufacturer = entry.manufacturer;
    p.countryOfManufacture = entry.countryOfManufacture;
    p.presumedEra = entry.presumedEra;
    p.manufacturingMaterial = entry.manufacturingMaterial;
    p.grooveWidth = entry.grooveWidth;
    p.grooveDepth = entry.grooveDepth;
    p.adjustments = entry.adjustments;
    p.bladeShape = entry.bladeShape;
    p.conditionState = entry.conditionState;
    p.stampsAndMarkings = entry.stampsAndMarkings;
    p.regionalFeatures = entry.regionalFeatures;
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
