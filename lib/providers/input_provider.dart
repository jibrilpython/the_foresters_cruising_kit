import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_foresters_cruising_kit/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _cruiserIdentifier = '';
  ToolType _toolType = ToolType.clinometer;
  String _specificFunction = '';
  String _manufacturer = '';
  String _countryOfOrigin = '';
  String _eraOfProduction = '';
  ScaleSystem _scaleSystem = ScaleSystem.metric;
  PrimaryMaterial _primaryMaterial = PrimaryMaterial.brass;
  OperatingPrinciple _operatingPrinciple = OperatingPrinciple.mechanical;
  String _dimensionsAndWeight = '';
  ConditionGrade _conditionGrade = ConditionGrade.unknown;
  TimberRegion _timberRegion = TimberRegion.other;
  String _includedAccessories = '';
  String _markingsAndStamps = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get cruiserIdentifier => _cruiserIdentifier;
  ToolType get toolType => _toolType;
  String get specificFunction => _specificFunction;
  String get manufacturer => _manufacturer;
  String get countryOfOrigin => _countryOfOrigin;
  String get eraOfProduction => _eraOfProduction;
  ScaleSystem get scaleSystem => _scaleSystem;
  PrimaryMaterial get primaryMaterial => _primaryMaterial;
  OperatingPrinciple get operatingPrinciple => _operatingPrinciple;
  String get dimensionsAndWeight => _dimensionsAndWeight;
  ConditionGrade get conditionGrade => _conditionGrade;
  TimberRegion get timberRegion => _timberRegion;
  String get includedAccessories => _includedAccessories;
  String get markingsAndStamps => _markingsAndStamps;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set cruiserIdentifier(String v) { _cruiserIdentifier = v; notifyListeners(); }
  set toolType(ToolType v) { _toolType = v; notifyListeners(); }
  set specificFunction(String v) { _specificFunction = v; notifyListeners(); }
  set manufacturer(String v) { _manufacturer = v; notifyListeners(); }
  set countryOfOrigin(String v) { _countryOfOrigin = v; notifyListeners(); }
  set eraOfProduction(String v) { _eraOfProduction = v; notifyListeners(); }
  set scaleSystem(ScaleSystem v) { _scaleSystem = v; notifyListeners(); }
  set primaryMaterial(PrimaryMaterial v) { _primaryMaterial = v; notifyListeners(); }
  set operatingPrinciple(OperatingPrinciple v) { _operatingPrinciple = v; notifyListeners(); }
  set dimensionsAndWeight(String v) { _dimensionsAndWeight = v; notifyListeners(); }
  set conditionGrade(ConditionGrade v) { _conditionGrade = v; notifyListeners(); }
  set timberRegion(TimberRegion v) { _timberRegion = v; notifyListeners(); }
  set includedAccessories(String v) { _includedAccessories = v; notifyListeners(); }
  set markingsAndStamps(String v) { _markingsAndStamps = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _cruiserIdentifier = '';
    _toolType = ToolType.clinometer;
    _specificFunction = '';
    _manufacturer = '';
    _countryOfOrigin = '';
    _eraOfProduction = '';
    _scaleSystem = ScaleSystem.metric;
    _primaryMaterial = PrimaryMaterial.brass;
    _operatingPrinciple = OperatingPrinciple.mechanical;
    _dimensionsAndWeight = '';
    _conditionGrade = ConditionGrade.unknown;
    _timberRegion = TimberRegion.other;
    _includedAccessories = '';
    _markingsAndStamps = '';
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
