import 'package:the_foresters_cruising_kit/enum/my_enums.dart';

class ForestryInstrumentModel {
  String id;
  String cruiserIdentifier;
  ToolType toolType;
  String specificFunction;
  String manufacturer;
  String countryOfOrigin;
  String eraOfProduction;
  ScaleSystem scaleSystem;
  PrimaryMaterial primaryMaterial;
  OperatingPrinciple operatingPrinciple;
  String dimensionsAndWeight;
  ConditionGrade conditionGrade;
  TimberRegion timberRegion;
  String includedAccessories;
  String markingsAndStamps;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  ForestryInstrumentModel({
    required this.id,
    required this.cruiserIdentifier,
    required this.toolType,
    required this.specificFunction,
    required this.manufacturer,
    required this.countryOfOrigin,
    required this.eraOfProduction,
    required this.scaleSystem,
    required this.primaryMaterial,
    required this.operatingPrinciple,
    required this.dimensionsAndWeight,
    required this.conditionGrade,
    required this.timberRegion,
    required this.includedAccessories,
    required this.markingsAndStamps,
    required this.provenance,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cruiserIdentifier': cruiserIdentifier,
        'toolType': toolType.name,
        'specificFunction': specificFunction,
        'manufacturer': manufacturer,
        'countryOfOrigin': countryOfOrigin,
        'eraOfProduction': eraOfProduction,
        'scaleSystem': scaleSystem.name,
        'primaryMaterial': primaryMaterial.name,
        'operatingPrinciple': operatingPrinciple.name,
        'dimensionsAndWeight': dimensionsAndWeight,
        'conditionGrade': conditionGrade.name,
        'timberRegion': timberRegion.name,
        'includedAccessories': includedAccessories,
        'markingsAndStamps': markingsAndStamps,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory ForestryInstrumentModel.fromJson(Map<String, dynamic> json) =>
      ForestryInstrumentModel(
        id: json['id'] ?? '',
        cruiserIdentifier: json['cruiserIdentifier'] ?? '',
        toolType: ToolType.values.asNameMap()[json['toolType']] ??
            ToolType.clinometer,
        specificFunction: json['specificFunction'] ?? '',
        manufacturer: json['manufacturer'] ?? '',
        countryOfOrigin: json['countryOfOrigin'] ?? '',
        eraOfProduction: json['eraOfProduction'] ?? '',
        scaleSystem: ScaleSystem.values.asNameMap()[json['scaleSystem']] ??
            ScaleSystem.metric,
        primaryMaterial:
            PrimaryMaterial.values.asNameMap()[json['primaryMaterial']] ??
                PrimaryMaterial.brass,
        operatingPrinciple: OperatingPrinciple.values
                .asNameMap()[json['operatingPrinciple']] ??
            OperatingPrinciple.mechanical,
        dimensionsAndWeight: json['dimensionsAndWeight'] ?? '',
        conditionGrade:
            ConditionGrade.values.asNameMap()[json['conditionGrade']] ??
                ConditionGrade.unknown,
        timberRegion:
            TimberRegion.values.asNameMap()[json['timberRegion']] ??
                TimberRegion.other,
        includedAccessories: json['includedAccessories'] ?? '',
        markingsAndStamps: json['markingsAndStamps'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
