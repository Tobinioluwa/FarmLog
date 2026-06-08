// lib/screens/add_crop_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/crop.dart';
import '../services/farm_service.dart';

class AddCropScreen extends StatefulWidget {
  final Crop? existing;
  const AddCropScreen({super.key, this.existing});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _location, _size, _notes;
  DateTime _plantedDate = DateTime.now();
  DateTime? _harvestDate;
  GrowthStage _stage = GrowthStage.planted;
  final _service = FarmService();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _size = TextEditingController(text: e != null ? '${e.farmSizeHectares}' : '');
    _notes = TextEditingController(text: e?.notes ?? '');
    if (e != null) {
      _plantedDate = e.plantedDate;
      _harvestDate = e.expectedHarvestDate;
      _stage = e.stage;
    }
  }

  @override
  void dispose() {
    _name.dispose(); _location.dispose(); _size.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isPlanted) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPlanted ? _plantedDate : (_harvestDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF76C442)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isPlanted ? _plantedDate = picked : _harvestDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    if (widget.existing != null) {
      final updated = widget.existing!;
      updated.name = _name.text.trim();
      updated.location = _location.text.trim();
      updated.farmSizeHectares = double.parse(_size.text.trim());
      updated.plantedDate = _plantedDate;
      updated.expectedHarvestDate = _harvestDate;
      updated.stage = _stage;
      updated.notes = _notes.text.trim();
      await _service.updateCrop(updated);
    } else {
      await _service.addCrop(Crop(
        id: const Uuid().v4(),
        name: _name.text.trim(),
        location: _location.text.trim(),
        farmSizeHectares: double.parse(_size.text.trim()),
        plantedDate: _plantedDate,
        expectedHarvestDate: _harvestDate,
        stage: _stage,
        notes: _notes.text.trim(),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.existing == null ? 'Add Crop' : 'Edit Crop',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(
                color: Color(0xFF76C442), fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label('Crop Name'),
            _field(_name, 'e.g. Maize, Cassava, Tomatoes', validator: (v) =>
                v == null || v.isEmpty ? 'Enter crop name' : null),
            const SizedBox(height: 16),
            _label('Farm Location'),
            _field(_location, 'e.g. Kaduna North, Benue'),
            const SizedBox(height: 16),
            _label('Farm Size (Hectares)'),
            _field(_size, 'e.g. 2.5',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter farm size';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                }),
            const SizedBox(height: 16),
            _label('Growth Stage'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GrowthStage.values.map((s) {
                final selected = _stage == s;
                return ChoiceChip(
                  label: Text('${s.emoji} ${s.label}',
                      style: TextStyle(
                          color: selected ? Colors.black : Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  selected: selected,
                  selectedColor: const Color(0xFF76C442),
                  backgroundColor: const Color(0xFF1A2E1C),
                  onSelected: (_) => setState(() => _stage = s),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Planted Date'),
            _dateTile(DateFormat('dd MMM yyyy').format(_plantedDate),
                () => _pickDate(true)),
            const SizedBox(height: 16),
            _label('Expected Harvest Date (optional)'),
            _dateTile(
              _harvestDate == null
                  ? 'Tap to set'
                  : DateFormat('dd MMM yyyy').format(_harvestDate!),
              () => _pickDate(false),
            ),
            const SizedBox(height: 16),
            _label('Notes (optional)'),
            _field(_notes, 'Any extra details...', maxLines: 3),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      );

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        filled: true,
        fillColor: const Color(0xFF1A2E1C),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _dateTile(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF76C442), size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
