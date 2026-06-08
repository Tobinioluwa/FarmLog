// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crop.dart';
import '../services/farm_service.dart';
import 'add_crop_screen.dart';
import 'crop_detail_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = FarmService();
  List<Crop> _crops = [];
  bool _loading = true;
  GrowthStage? _filterStage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final crops = await _service.loadCrops();
    crops.sort((a, b) => b.plantedDate.compareTo(a.plantedDate));
    setState(() { _crops = crops; _loading = false; });
  }

  List<Crop> get _filtered => _filterStage == null
      ? _crops
      : _crops.where((c) => c.stage == _filterStage).toList();

  double get _totalProfitLoss =>
      _crops.fold(0, (sum, c) => sum + c.profitLoss);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSummaryCards(),
            _buildFilterChips(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF76C442)))
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _CropTile(
                            crop: _filtered[i],
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(
                                builder: (_) => CropDetailScreen(cropId: _filtered[i].id),
                              ));
                              _load();
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddCropScreen()));
          _load();
        },
        backgroundColor: const Color(0xFF76C442),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Crop', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌾 FarmLog',
                    style: TextStyle(color: Color(0xFF76C442), fontSize: 13,
                        fontWeight: FontWeight.w700, letterSpacing: 2)),
                const Text('My Farm',
                    style: TextStyle(color: Colors.white, fontSize: 28,
                        fontWeight: FontWeight.w800)),
                Text('${_crops.length} crop${_crops.length == 1 ? '' : 's'} logged',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white.withOpacity(0.5)),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final active = _crops.where((c) => c.stage != GrowthStage.harvested).length;
    final harvested = _crops.where((c) => c.stage == GrowthStage.harvested).length;
    final pnl = _totalProfitLoss;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _summaryCard('Active', '$active', Icons.eco_outlined, const Color(0xFF76C442)),
          const SizedBox(width: 10),
          _summaryCard('Harvested', '$harvested', Icons.inventory_2_outlined, const Color(0xFFFFD166)),
          const SizedBox(width: 10),
          _summaryCard(
            pnl >= 0 ? 'Profit' : 'Loss',
            '₦${NumberFormat('#,###').format(pnl.abs())}',
            pnl >= 0 ? Icons.trending_up : Icons.trending_down,
            pnl >= 0 ? const Color(0xFF76C442) : Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final stages = [null, ...GrowthStage.values];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stages.length,
        itemBuilder: (_, i) {
          final s = stages[i];
          final selected = _filterStage == s;
          final label = s == null ? 'All' : '${s.emoji} ${s.label}';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label, style: TextStyle(
                  color: selected ? Colors.black : Colors.white.withOpacity(0.6),
                  fontSize: 12, fontWeight: FontWeight.w600)),
              selected: selected,
              selectedColor: const Color(0xFF76C442),
              backgroundColor: const Color(0xFF1A2E1C),
              onSelected: (_) => setState(() => _filterStage = s),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌱', style: TextStyle(fontSize: 60, color: Colors.white.withOpacity(0.15))),
          const SizedBox(height: 16),
          Text(_filterStage == null ? 'No crops logged yet' : 'No crops in this stage',
              style: TextStyle(color: Colors.white.withOpacity(0.3),
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap + Add Crop to get started',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13)),
        ],
      ),
    );
  }
}

class _CropTile extends StatelessWidget {
  final Crop crop;
  final VoidCallback onTap;
  const _CropTile({required this.crop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = crop.daysToHarvest;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(crop.stage.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(crop.name,
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('📍 ${crop.location}  •  ${crop.farmSizeHectares} ha',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _stageColor(crop.stage).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(crop.stage.label,
                      style: TextStyle(
                          color: _stageColor(crop.stage),
                          fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat('Day ${crop.daysSincePlanting}', 'Since Planting'),
                _stat(days == null
                    ? '—'
                    : days < 0
                        ? '${days.abs()}d overdue'
                        : '${days}d left',
                    'To Harvest',
                    color: days != null && days < 0 ? Colors.redAccent : null),
                _stat('₦${NumberFormat('#,###').format(crop.totalCosts)}', 'Total Cost'),
                _stat(
                  crop.profitLoss >= 0
                      ? '+₦${NumberFormat('#,###').format(crop.profitLoss)}'
                      : '-₦${NumberFormat('#,###').format(crop.profitLoss.abs())}',
                  'P&L',
                  color: crop.profitLoss >= 0 ? const Color(0xFF76C442) : Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _stageColor(GrowthStage s) {
    switch (s) {
      case GrowthStage.planted: return const Color(0xFF76C442);
      case GrowthStage.growing: return const Color(0xFF4FC3F7);
      case GrowthStage.ready: return const Color(0xFFFFD166);
      case GrowthStage.harvested: return Colors.white54;
    }
  }

  Widget _stat(String value, String label, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 13, fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
        ],
      ),
    );
  }
}
