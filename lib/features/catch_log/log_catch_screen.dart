import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/angler_button.dart';
import '../../data/models/catch_record.dart';
import '../../data/providers/app_state.dart';

class LogCatchScreen extends StatefulWidget {
  const LogCatchScreen({super.key});

  @override
  State<LogCatchScreen> createState() => _LogCatchScreenState();
}

class _LogCatchScreenState extends State<LogCatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedSpecies;
  String? _selectedBait;
  String? _selectedClarity;
  double? _weight;
  double? _length;
  double? _depth;
  DateTime _catchTime = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _catchTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentOrange,
              surface: AppColors.surfaceCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_catchTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.accentOrange,
                surface: AppColors.surfaceCard,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _catchTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveCatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecies == null || _selectedBait == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select species and bait'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final appState = context.read<AppState>();
    final location = appState.currentLocation ??
        const LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude);

    final catchRecord = CatchRecord(
      id: const Uuid().v4(),
      species: _selectedSpecies!,
      weight: _weight,
      length: _length,
      baitUsed: _selectedBait!,
      depth: _depth,
      timestamp: _catchTime,
      location: location,
      waterConditions: _selectedClarity != null
          ? WaterConditions(clarity: _selectedClarity!)
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await appState.addCatch(catchRecord);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catch logged successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapDark,
      appBar: AppBar(
        title: const Text('Log Catch'),
        backgroundColor: AppColors.mapDark,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Fish Details'),
            _buildDropdownField(
              label: 'Species',
              value: _selectedSpecies,
              items: AppConstants.fishSpecies,
              onChanged: (value) => setState(() => _selectedSpecies = value),
              icon: Icons.set_meal,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Weight (lbs)',
                    onChanged: (value) => _weight = double.tryParse(value),
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'Length (in)',
                    onChanged: (value) => _length = double.tryParse(value),
                    icon: Icons.straighten,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Fishing Details'),
            _buildDropdownField(
              label: 'Bait / Lure',
              value: _selectedBait,
              items: AppConstants.baitTypes,
              onChanged: (value) => setState(() => _selectedBait = value),
              icon: Icons.catching_pokemon,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Depth (ft)',
                    onChanged: (value) => _depth = double.tryParse(value),
                    icon: Icons.water,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Water Clarity',
                    value: _selectedClarity,
                    items: AppConstants.waterClarity,
                    onChanged: (value) =>
                        setState(() => _selectedClarity = value),
                    icon: Icons.visibility,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('When & Where'),
            _buildDateTimeField(),
            const SizedBox(height: 16),
            _buildLocationDisplay(),
            const SizedBox(height: 24),
            _buildSectionTitle('Notes'),
            _buildNotesField(),
            const SizedBox(height: 32),
            AnglerButton(
              label: 'Save Catch',
              icon: Icons.save,
              isLoading: _isLoading,
              onPressed: _saveCatch,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.accentOrange,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        dropdownColor: AppColors.surfaceCard,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return TextFormField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDateTimeField() {
    return GestureDetector(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date & Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a').format(_catchTime),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDisplay() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final location = appState.currentLocation;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.accentOrange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      location != null
                          ? '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'
                          : 'Location unavailable',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (location != null)
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Additional notes...',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.notes, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
