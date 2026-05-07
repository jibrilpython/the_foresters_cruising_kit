import 'package:coopering_croze_barrel/enum/my_enums.dart';

class CrozeModel {
  String id;
  String cooperageIdentifier;
  CrozeType crozeType;
  BarrelType barrelType;
  String specialization;
  String barrelVolume;
  String manufacturer;
  String countryOfManufacture;
  String presumedEra;
  ManufacturingMaterial manufacturingMaterial;
  String grooveWidth;
  String grooveDepth;
  String adjustments;
  String bladeShape;
  CrozeCondition conditionState;
  String stampsAndMarkings;
  String regionalFeatures;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  CrozeModel({
    required this.id,
    required this.cooperageIdentifier,
    required this.crozeType,
    required this.barrelType,
    required this.specialization,
    required this.barrelVolume,
    required this.manufacturer,
    required this.countryOfManufacture,
    required this.presumedEra,
    required this.manufacturingMaterial,
    required this.grooveWidth,
    required this.grooveDepth,
    required this.adjustments,
    required this.bladeShape,
    required this.conditionState,
    required this.stampsAndMarkings,
    required this.regionalFeatures,
    required this.provenance,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cooperageIdentifier': cooperageIdentifier,
        'crozeType': crozeType.name,
        'barrelType': barrelType.name,
        'specialization': specialization,
        'barrelVolume': barrelVolume,
        'manufacturer': manufacturer,
        'countryOfManufacture': countryOfManufacture,
        'presumedEra': presumedEra,
        'manufacturingMaterial': manufacturingMaterial.name,
        'grooveWidth': grooveWidth,
        'grooveDepth': grooveDepth,
        'adjustments': adjustments,
        'bladeShape': bladeShape,
        'conditionState': conditionState.name,
        'stampsAndMarkings': stampsAndMarkings,
        'regionalFeatures': regionalFeatures,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory CrozeModel.fromJson(Map<String, dynamic> json) => CrozeModel(
        id: json['id'] ?? '',
        cooperageIdentifier: json['cooperageIdentifier'] ?? '',
        crozeType: CrozeType.values.asNameMap()[json['crozeType']] ?? CrozeType.other,
        barrelType: BarrelType.values.asNameMap()[json['barrelType']] ?? BarrelType.other,
        specialization: json['specialization'] ?? '',
        barrelVolume: json['barrelVolume'] ?? '',
        manufacturer: json['manufacturer'] ?? '',
        countryOfManufacture: json['countryOfManufacture'] ?? '',
        presumedEra: json['presumedEra'] ?? '',
        manufacturingMaterial: ManufacturingMaterial.values.asNameMap()[json['manufacturingMaterial']] ?? ManufacturingMaterial.castIron,
        grooveWidth: json['grooveWidth'] ?? '',
        grooveDepth: json['grooveDepth'] ?? '',
        adjustments: json['adjustments'] ?? '',
        bladeShape: json['bladeShape'] ?? '',
        conditionState: CrozeCondition.values.asNameMap()[json['conditionState']] ?? CrozeCondition.unknown,
        stampsAndMarkings: json['stampsAndMarkings'] ?? '',
        regionalFeatures: json['regionalFeatures'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
