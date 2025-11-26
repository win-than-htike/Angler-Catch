import 'dart:io';
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
import '../../data/services/photo_service.dart';

class LogCatchScreen extends StatefulWidget {
  const LogCatchScreen({super.key});

  @override
  State<LogCatchScreen> createState() => _LogCatchScreenState();
}

class _LogCatchScreenState extends State<LogCatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _photoService = PhotoService();

  String? _selectedSpecies;
  String? _selectedBait;
  String? _selectedClarity;
  double? _weight;
  double? _length;
  double? _depth;
  DateTime _catchTime = DateTime.now();
  bool _isLoading = false;
  String? _photoPath;

  @override
  void dispose() {
    _notesController.dispose();
    // Note: Don't delete photo here - user might navigate back and return
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final path = await _photoService.takePhoto();
    if (path != null) {
      // Delete old photo if replacing
      if (_photoPath != null) {
        await _photoService.deletePhoto(_photoPath);
      }
      setState(() => _photoPath = path);
    }
  }

  Future<void> _pickFromGallery() async {
    final path = await _photoService.pickFromGallery();
    if (path != null) {
      // Delete old photo if replacing
      if (_photoPath != null) {
        await _photoService.deletePhoto(_photoPath);
      }
      setState(() => _photoPath = path);
    }
  }

  Future<void> _removePhoto() async {
    if (_photoPath != null) {
      await _photoService.deletePhoto(_photoPath);
      setState(() => _photoPath = null);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.accentOrange,
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.accentGold,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
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
    final location =
        appState.currentLocation ??
        const LatLng(
          AppConstants.defaultLatitude,
          AppConstants.defaultLongitude,
        );

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
      photoUrl: _photoPath,
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
            _buildSectionTitle('Photo'),
            _buildPhotoSection(),
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
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
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

  Widget _buildPhotoSection() {
    if (_photoPath != null) {
      return GestureDetector(
        onTap: _showPhotoOptions,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(_photoPath!), fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _removePhoto,
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Tap to change',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textMuted.withAlpha(100),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: AppColors.textMuted, size: 40),
            SizedBox(height: 8),
            Text(
              'Add a photo of your catch',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
