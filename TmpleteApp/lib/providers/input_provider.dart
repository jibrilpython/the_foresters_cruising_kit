import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopering_croze_barrel/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _cooperageIdentifier = '';
  CrozeType _crozeType = CrozeType.handCroze;
  BarrelType _barrelType = BarrelType.whiskey;
  String _specialization = '';
  String _barrelVolume = '';
  String _manufacturer = '';
  String _countryOfManufacture = '';
  String _presumedEra = '';
  ManufacturingMaterial _manufacturingMaterial = ManufacturingMaterial.castIron;
  String _grooveWidth = '';
  String _grooveDepth = '';
  String _adjustments = '';
  String _bladeShape = '';
  CrozeCondition _conditionState = CrozeCondition.unknown;
  String _stampsAndMarkings = '';
  String _regionalFeatures = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get cooperageIdentifier => _cooperageIdentifier;
  CrozeType get crozeType => _crozeType;
  BarrelType get barrelType => _barrelType;
  String get specialization => _specialization;
  String get barrelVolume => _barrelVolume;
  String get manufacturer => _manufacturer;
  String get countryOfManufacture => _countryOfManufacture;
  String get presumedEra => _presumedEra;
  ManufacturingMaterial get manufacturingMaterial => _manufacturingMaterial;
  String get grooveWidth => _grooveWidth;
  String get grooveDepth => _grooveDepth;
  String get adjustments => _adjustments;
  String get bladeShape => _bladeShape;
  CrozeCondition get conditionState => _conditionState;
  String get stampsAndMarkings => _stampsAndMarkings;
  String get regionalFeatures => _regionalFeatures;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set cooperageIdentifier(String v) { _cooperageIdentifier = v; notifyListeners(); }
  set crozeType(CrozeType v) { _crozeType = v; notifyListeners(); }
  set barrelType(BarrelType v) { _barrelType = v; notifyListeners(); }
  set specialization(String v) { _specialization = v; notifyListeners(); }
  set barrelVolume(String v) { _barrelVolume = v; notifyListeners(); }
  set manufacturer(String v) { _manufacturer = v; notifyListeners(); }
  set countryOfManufacture(String v) { _countryOfManufacture = v; notifyListeners(); }
  set presumedEra(String v) { _presumedEra = v; notifyListeners(); }
  set manufacturingMaterial(ManufacturingMaterial v) { _manufacturingMaterial = v; notifyListeners(); }
  set grooveWidth(String v) { _grooveWidth = v; notifyListeners(); }
  set grooveDepth(String v) { _grooveDepth = v; notifyListeners(); }
  set adjustments(String v) { _adjustments = v; notifyListeners(); }
  set bladeShape(String v) { _bladeShape = v; notifyListeners(); }
  set conditionState(CrozeCondition v) { _conditionState = v; notifyListeners(); }
  set stampsAndMarkings(String v) { _stampsAndMarkings = v; notifyListeners(); }
  set regionalFeatures(String v) { _regionalFeatures = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _cooperageIdentifier = '';
    _crozeType = CrozeType.handCroze;
    _barrelType = BarrelType.whiskey;
    _specialization = '';
    _barrelVolume = '';
    _manufacturer = '';
    _countryOfManufacture = '';
    _presumedEra = '';
    _manufacturingMaterial = ManufacturingMaterial.castIron;
    _grooveWidth = '';
    _grooveDepth = '';
    _adjustments = '';
    _bladeShape = '';
    _conditionState = CrozeCondition.unknown;
    _stampsAndMarkings = '';
    _regionalFeatures = '';
    _provenance = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
