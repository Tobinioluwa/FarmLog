// lib/models/crop.dart
import 'dart:convert';

enum GrowthStage { planted, growing, ready, harvested }

extension GrowthStageLabel on GrowthStage {
  String get label {
    switch (this) {
      case GrowthStage.planted: return 'Planted';
      case GrowthStage.growing: return 'Growing';
      case GrowthStage.ready: return 'Ready to Harvest';
      case GrowthStage.harvested: return 'Harvested';
    }
  }

  String get emoji {
    switch (this) {
      case GrowthStage.planted: return '🌱';
      case GrowthStage.growing: return '🌿';
      case GrowthStage.ready: return '🌾';
      case GrowthStage.harvested: return '📦';
    }
  }
}

class InputCost {
  final String id;
  final String category; // Seeds, Fertiliser, Labour, Pesticides, Other
  final String description;
  final double amount;
  final DateTime date;

  InputCost({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory InputCost.fromJson(Map<String, dynamic> j) => InputCost(
        id: j['id'],
        category: j['category'],
        description: j['description'],
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.parse(j['date']),
      );
}

class Crop {
  final String id;
  String name;
  String location;
  double farmSizeHectares;
  DateTime plantedDate;
  DateTime? expectedHarvestDate;
  GrowthStage stage;
  List<InputCost> costs;
  double? harvestQuantityKg;
  double? estimatedSaleValueNaira;
  String notes;

  Crop({
    required this.id,
    required this.name,
    required this.location,
    required this.farmSizeHectares,
    required this.plantedDate,
    this.expectedHarvestDate,
    this.stage = GrowthStage.planted,
    List<InputCost>? costs,
    this.harvestQuantityKg,
    this.estimatedSaleValueNaira,
    this.notes = '',
  }) : costs = costs ?? [];

  double get totalCosts => costs.fold(0, (sum, c) => sum + c.amount);
  double get profitLoss => (estimatedSaleValueNaira ?? 0) - totalCosts;

  int get daysSincePlanting =>
      DateTime.now().difference(plantedDate).inDays;

  int? get daysToHarvest => expectedHarvestDate == null
      ? null
      : expectedHarvestDate!.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'farmSizeHectares': farmSizeHectares,
        'plantedDate': plantedDate.toIso8601String(),
        'expectedHarvestDate': expectedHarvestDate?.toIso8601String(),
        'stage': stage.index,
        'costs': costs.map((c) => c.toJson()).toList(),
        'harvestQuantityKg': harvestQuantityKg,
        'estimatedSaleValueNaira': estimatedSaleValueNaira,
        'notes': notes,
      };

  factory Crop.fromJson(Map<String, dynamic> j) => Crop(
        id: j['id'],
        name: j['name'],
        location: j['location'],
        farmSizeHectares: (j['farmSizeHectares'] as num).toDouble(),
        plantedDate: DateTime.parse(j['plantedDate']),
        expectedHarvestDate: j['expectedHarvestDate'] != null
            ? DateTime.parse(j['expectedHarvestDate'])
            : null,
        stage: GrowthStage.values[j['stage']],
        costs: (j['costs'] as List).map((c) => InputCost.fromJson(c)).toList(),
        harvestQuantityKg: j['harvestQuantityKg'] != null
            ? (j['harvestQuantityKg'] as num).toDouble()
            : null,
        estimatedSaleValueNaira: j['estimatedSaleValueNaira'] != null
            ? (j['estimatedSaleValueNaira'] as num).toDouble()
            : null,
        notes: j['notes'] ?? '',
      );
}
