// lib/screens/crop_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/crop.dart';
import '../services/farm_service.dart';
import 'add_crop_screen.dart';

const _costCategories = ['Seeds', 'Fertiliser', 'Labour', 'Pesticides', 'Equipment', 'Other'];

class CropDetailScreen extends StatefulWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  final _service = FarmService();
  Crop? _crop;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final crops = await _service.loadCrops();
    setState(() => _crop = crops.firstWhere((c) => c.id == widget.cropId));
  }

  Future<void> _addCost() async {
    final catCtrl = ValueNotifier<String>(_costCategories[0]);
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2E1C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Input Cost',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: catCtrl,
              builder: (_, val, __) => DropdownButtonFormField<String>(
                value: val,
                dropdownColor: const Color(0xFF1A2E1C),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Category'),
                items: _costCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => catCtrl.value = v!,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Description (e.g. NPK fertiliser, 50kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Amount (₦)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF76C442),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  final amt = double.tryParse(amtCtrl.text.trim());
                  if (amt == null) return;
                  _crop!.costs.add(InputCost(
                    id: const Uuid().v4(),
                    category: catCtrl.value,
                    description: descCtrl.text.trim(),
                    amount: amt,
                    date: DateTime.now(),
                  ));
                  await _service.updateCrop(_crop!);
                  if (mounted) Navigator.pop(ctx);
                  _load();
                },
                child: const Text('Save Cost', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logHarvest() async {
    final qtyCtrl = TextEditingController(
        text: _crop!.harvestQuantityKg != null ? '${_crop!.harvestQuantityKg}' : '');
    final valCtrl = TextEditingController(
        text: _crop!.estimatedSaleValueNaira != null
            ? '${_crop!.estimatedSaleValueNaira}'
            : '');

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2E1C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Harvest',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Harvest Quantity (kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Estimated Sale Value (₦)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD166),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  _crop!.harvestQuantityKg = double.tryParse(qtyCtrl.text.trim());
                  _crop!.estimatedSaleValueNaira = double.tryParse(valCtrl.text.trim());
                  _crop!.stage = GrowthStage.harvested;
                  await _service.updateCrop(_crop!);
                  if (mounted) Navigator.pop(ctx);
                  _load();
                },
                child: const Text('Mark as Harvested', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_crop == null) {
      return const Scaffold(
          backgroundColor: Color(0xFF0D1F0F),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF76C442))));
    }
    final c = _crop!;
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(c.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white70),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddCropScreen(existing: c)));
              _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1A2E1C),
                  title: const Text('Delete Crop?', style: TextStyle(color: Colors.white)),
                  content: Text('This will permanently delete ${c.name}.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                    TextButton(onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              );
              if (confirm == true) {
                await _service.deleteCrop(c.id);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoCard(c),
          const SizedBox(height: 16),
          _pnlCard(c, fmt),
          const SizedBox(height: 16),
          _costsSection(c, fmt),
          const SizedBox(height: 16),
          if (c.stage != GrowthStage.harvested)
            ElevatedButton.icon(
              onPressed: _logHarvest,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Log Harvest', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          if (c.harvestQuantityKg != null) ...[
            const SizedBox(height: 12),
            _harvestCard(c, fmt),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _infoCard(Crop c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2E1C), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(c.stage.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('📍 ${c.location}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF76C442).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c.stage.label,
                    style: const TextStyle(
                        color: Color(0xFF76C442), fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          _infoRow('Farm Size', '${c.farmSizeHectares} hectares'),
          _infoRow('Planted', DateFormat('dd MMM yyyy').format(c.plantedDate)),
          _infoRow('Days Growing', '${c.daysSincePlanting} days'),
          if (c.expectedHarvestDate != null)
            _infoRow('Expected Harvest',
                DateFormat('dd MMM yyyy').format(c.expectedHarvestDate!),
                accent: c.daysToHarvest != null && c.daysToHarvest! < 0
                    ? Colors.redAccent
                    : null),
          if (c.notes.isNotEmpty) _infoRow('Notes', c.notes),
        ],
      ),
    );
  }

  Widget _pnlCard(Crop c, NumberFormat fmt) {
    final pnl = c.profitLoss;
    final isProfit = pnl >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isProfit
            ? const Color(0xFF76C442).withOpacity(0.1)
            : Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isProfit
              ? const Color(0xFF76C442).withOpacity(0.3)
              : Colors.redAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(isProfit ? Icons.trending_up : Icons.trending_down,
              color: isProfit ? const Color(0xFF76C442) : Colors.redAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isProfit ? 'Estimated Profit' : 'Current Loss',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12)),
                Text(
                  '${isProfit ? '+' : '-'}₦${fmt.format(pnl.abs())}',
                  style: TextStyle(
                      color: isProfit ? const Color(0xFF76C442) : Colors.redAccent,
                      fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Revenue: ₦${fmt.format(c.estimatedSaleValueNaira ?? 0)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              Text('Costs: ₦${fmt.format(c.totalCosts)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costsSection(Crop c, NumberFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Input Costs',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton.icon(
              onPressed: _addCost,
              icon: const Icon(Icons.add, color: Color(0xFF76C442), size: 18),
              label: const Text('Add Cost',
                  style: TextStyle(color: Color(0xFF76C442), fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (c.costs.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF1A2E1C), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text('No costs logged yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.3))),
            ),
          )
        else
          ...c.costs.map((cost) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF1A2E1C),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF76C442).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(cost.category,
                          style: const TextStyle(
                              color: Color(0xFF76C442), fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(cost.description.isNotEmpty ? cost.description : cost.category,
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                    Text('₦${fmt.format(cost.amount)}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              Text('₦${fmt.format(c.totalCosts)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _harvestCard(Crop c, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📦 Harvest Record',
              style: TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          if (c.harvestQuantityKg != null)
            _infoRow('Quantity', '${c.harvestQuantityKg} kg'),
          if (c.estimatedSaleValueNaira != null)
            _infoRow('Sale Value', '₦${fmt.format(c.estimatedSaleValueNaira)}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? accent}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    color: accent ?? Colors.white,
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: const Color(0xFF0D1F0F),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
