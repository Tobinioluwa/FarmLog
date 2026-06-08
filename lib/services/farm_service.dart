// lib/services/farm_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop.dart';

class FarmService {
  static const _key = 'farmlog_crops';

  Future<List<Crop>> loadCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Crop.fromJson(e)).toList();
  }

  Future<void> saveCrops(List<Crop> crops) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(crops.map((c) => c.toJson()).toList()));
  }

  Future<void> addCrop(Crop crop) async {
    final crops = await loadCrops();
    crops.add(crop);
    await saveCrops(crops);
  }

  Future<void> updateCrop(Crop updated) async {
    final crops = await loadCrops();
    final idx = crops.indexWhere((c) => c.id == updated.id);
    if (idx != -1) crops[idx] = updated;
    await saveCrops(crops);
  }

  Future<void> deleteCrop(String id) async {
    final crops = await loadCrops();
    crops.removeWhere((c) => c.id == id);
    await saveCrops(crops);
  }
}
