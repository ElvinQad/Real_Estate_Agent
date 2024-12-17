import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/voice_input_service.dart';
import 'package:avatar_glow/avatar_glow.dart';

class ClientFormDialog extends StatelessWidget {
  final Client? client;
  final Function(Map<String, dynamic>) onSave;

  const ClientFormDialog({
    Key? key,
    this.client,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.dialogBackgroundColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  client == null ? 'Add Client' : 'Edit Client',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: theme.dividerColor.withOpacity(0.1)),
            const SizedBox(height: 8),
            Expanded(
              child: ClientFormContent(
                client: client,
                onSave: onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientFormContent extends StatefulWidget {
  final Client? client;
  final Function(Map<String, dynamic>) onSave;

  const ClientFormContent({
    Key? key,
    this.client,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ClientFormContent> createState() => _ClientFormContentState();
}

class _ClientFormContentState extends State<ClientFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _minSquareMetersController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _desiredMoveInDate;
  List<String> _preferredLocations = [];
  List<int> _preferredRooms = [];
  List<String> _propertyTypes = [];
  List<String> _amenities = [];
  String? _preferredStyle;
  bool _hasParking = false;

  static const List<String> _availableStyles = [
    'Modern',
    'Traditional',
    'Contemporary',
    'Classical',
    'Minimalist',
    'Industrial',
  ];

  final VoiceInputService _voiceService = VoiceInputService();
  TextEditingController? _activeController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final client = widget.client;
    if (client == null) return;

    _nameController.text = client.name;
    _emailController.text = client.email;
    _phoneController.text = client.phone ?? '';
    _budgetMinController.text = client.budgetMin?.toString() ?? '';
    _budgetMaxController.text = client.budgetMax?.toString() ?? '';
    _minSquareMetersController.text = client.minSquareMeters?.toString() ?? '';
    _notesController.text = client.notes ?? '';
    _desiredMoveInDate = client.desiredMoveInDate;
    _preferredLocations = client.preferredLocations ?? [];
    _preferredRooms = client.preferredRooms ?? [];
    _propertyTypes = client.propertyTypes ?? [];
    _amenities = client.amenities ?? [];
    _preferredStyle = client.preferredStyle;
    _hasParking = client.hasParking ?? false;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final minSquareMeters = double.tryParse(_minSquareMetersController.text);
      final budgetMin = double.tryParse(_budgetMinController.text);
      final budgetMax = double.tryParse(_budgetMaxController.text);

      widget.onSave({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'minSquareMeters': minSquareMeters,
        'notes': _notesController.text,
        'desiredMoveInDate': _desiredMoveInDate?.toIso8601String(),
        'preferredLocations': _preferredLocations,
        'preferredRooms': _preferredRooms,
        'propertyTypes': _propertyTypes,
        'amenities': _amenities,
        'preferredStyle': _preferredStyle,
        'hasParking': _hasParking,
      });
    }
  }

  Widget _buildVoiceInputButton(TextEditingController controller) {
    return IconButton(
      icon: AvatarGlow(
        endRadius: 16.0,
        animate: _isListening && _activeController == controller,
        duration: const Duration(milliseconds: 2000),
        glowColor: Theme.of(context).colorScheme.primary,
        repeat: true,
        showTwoGlows: true,
        child: Icon(
          _isListening && _activeController == controller
              ? Icons.mic
              : Icons.mic_none,
          color: _isListening && _activeController == controller
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      onPressed: () => _handleVoiceInput(controller),
    );
  }

  Future<void> _handleVoiceInput(TextEditingController controller) async {
    if (!_voiceService.isPlatformSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not supported on this platform'),
        ),
      );
      return;
    }

    if (!_isListening) {
      final available = await _voiceService.initialize();
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
          ),
        );
        return;
      }

      setState(() {
        _isListening = true;
        _activeController = controller;
      });

      final result = await _voiceService.startListening();
      if (result != null) {
        controller.text = result;
      }

      setState(() {
        _isListening = false;
        _activeController = null;
      });
    } else {
      _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _activeController = null;
      });
    }
  }

  Future<void> _handleCompleteVoiceInput() async {
    if (!_voiceService.isPlatformSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not supported on this platform'),
        ),
      );
      return;
    }

    if (!_isListening) {
      final available = await _voiceService.initialize();
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
        return;
      }

      setState(() => _isListening = true);

      // Show recording dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Listening...'),
              const SizedBox(height: 8),
              Text(
                'Try saying something like:\n"Name is John, email is john@email.com, phone is 1234567890, '
                'budget is 500000, looking for 3 rooms, location is Downtown, '
                'property type is apartment, 100 square meters"',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      final result = await _voiceService.startListening();
      Navigator.pop(context); // Close recording dialog

      if (result != null) {
        final parsedData = _voiceService.parseClientDescription(result);
        _fillFormWithParsedData(parsedData);
      }

      setState(() => _isListening = false);
    } else {
      _voiceService.stopListening();
      setState(() => _isListening = false);
    }
  }

  void _fillFormWithParsedData(Map<String, dynamic> data) {
    if (data['name'] != null) _nameController.text = data['name'];
    if (data['email'] != null) _emailController.text = data['email'];
    if (data['phone'] != null) _phoneController.text = data['phone'];
    if (data['budgetMax'] != null)
      _budgetMaxController.text = data['budgetMax'].toString();
    if (data['minSquareMeters'] != null)
      _minSquareMetersController.text = data['minSquareMeters'].toString();
    if (data['preferredLocations'] != null)
      setState(() => _preferredLocations = data['preferredLocations']);
    if (data['preferredRooms'] != null)
      setState(() => _preferredRooms = data['preferredRooms']);
    if (data['propertyTypes'] != null)
      setState(() => _propertyTypes = data['propertyTypes']);
    if (data['notes'] != null) _notesController.text = data['notes'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSection(
                title: 'Basic Information',
                children: [
                  _buildRequiredField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  _buildRequiredField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Email is required';
                      if (!value!.contains('@')) return 'Invalid email format';
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              _buildSection(
                title: 'Budget',
                children: [
                  _buildNumericField(
                    controller: _budgetMinController,
                    label: 'Minimum Budget',
                    icon: Icons.attach_money_rounded,
                  ),
                  _buildNumericField(
                    controller: _budgetMaxController,
                    label: 'Maximum Budget',
                    icon: Icons.attach_money_rounded,
                  ),
                ],
              ),
              _buildSection(
                title: 'Preferences',
                children: [
                  _buildDatePicker(context),
                  const SizedBox(height: 16),
                  _buildLocationChips(),
                  const SizedBox(height: 16),
                  _buildPropertyTypeChips(),
                  const SizedBox(height: 16),
                  _buildPreferredRoomsChips(),
                  const SizedBox(height: 16),
                  _buildStyleDropdown(),
                  const SizedBox(height: 16),
                  _buildAmenitiesChips(),
                  SwitchListTile(
                    title: const Text('Parking Required'),
                    value: _hasParking,
                    onChanged: (value) => setState(() => _hasParking = value),
                  ),
                  _buildNumericField(
                    controller: _minSquareMetersController,
                    label: 'Minimum Square Meters',
                    icon: Icons.square_foot_rounded,
                  ),
                ],
              ),
              _buildSection(
                title: 'Additional Information',
                children: [
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Client',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _handleCompleteVoiceInput,
            child: AvatarGlow(
              endRadius: 25.0,
              animate: _isListening,
              duration: const Duration(milliseconds: 2000),
              glowColor: Theme.of(context).colorScheme.primary,
              repeat: true,
              showTwoGlows: true,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRequiredField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    IconData? icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label *',
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: _buildVoiceInputButton(controller),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        style: theme.textTheme.bodyLarge,
        validator: validator,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int? maxLines,
    IconData? icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: _buildVoiceInputButton(controller),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildNumericField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value?.isNotEmpty ?? false) {
            if (double.tryParse(value!) == null) {
              return 'Please enter a valid number';
            }
          }
          return validator?.call(value);
        },
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: const Text('Desired Move-in Date'),
      subtitle: Text(
        _desiredMoveInDate != null
            ? '${_desiredMoveInDate!.day}/${_desiredMoveInDate!.month}/${_desiredMoveInDate!.year}'
            : 'Not set',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _desiredMoveInDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          );
          if (date != null) {
            setState(() => _desiredMoveInDate = date);
          }
        },
      ),
    );
  }

  Widget _buildLocationChips() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferred Locations'),
        Wrap(
          spacing: 8,
          children: [
            ..._preferredLocations.map((location) => Chip(
                  label: Text(location),
                  onDeleted: () =>
                      setState(() => _preferredLocations.remove(location)),
                )),
            ActionChip(
              label: const Icon(Icons.add, size: 20),
              onPressed: () => _showAddDialog(
                context,
                'Add Location',
                (value) => setState(() => _preferredLocations.add(value)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyTypeChips() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Property Types'),
        Wrap(
          spacing: 8,
          children: [
            ..._propertyTypes.map((type) => Chip(
                  label: Text(type),
                  onDeleted: () => setState(() => _propertyTypes.remove(type)),
                )),
            ActionChip(
              label: const Icon(Icons.add, size: 20),
              onPressed: () => _showAddDialog(
                context,
                'Add Property Type',
                (value) => setState(() => _propertyTypes.add(value)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferredRoomsChips() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferred Number of Rooms'),
        Wrap(
          spacing: 8,
          children: [
            ..._preferredRooms.map((rooms) => Chip(
                  label: Text('$rooms rooms'),
                  onDeleted: () =>
                      setState(() => _preferredRooms.remove(rooms)),
                )),
            ActionChip(
              label: const Icon(Icons.add, size: 20),
              onPressed: () => _showRoomNumberDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleDropdown() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _preferredStyle,
        decoration: InputDecoration(
          labelText: 'Preferred Style',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('No preference')),
          ..._availableStyles.map(
            (style) => DropdownMenuItem(value: style, child: Text(style)),
          ),
        ],
        onChanged: (value) => setState(() => _preferredStyle = value),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildAmenitiesChips() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amenities'),
        Wrap(
          spacing: 8,
          children: [
            ..._amenities.map((amenity) => Chip(
                  label: Text(amenity),
                  onDeleted: () => setState(() => _amenities.remove(amenity)),
                )),
            ActionChip(
              label: const Icon(Icons.add, size: 20),
              onPressed: () => _showAddDialog(
                context,
                'Add Amenity',
                (value) => setState(() => _amenities.add(value)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddDialog(
    BuildContext context,
    String title,
    Function(String) onAdd,
  ) {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoomNumberDialog(BuildContext context) {
    int? selectedRooms;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Select Number of Rooms'),
        content: DropdownButton<int>(
          value: selectedRooms,
          items: List.generate(10, (i) => i + 1)
              .map((rooms) => DropdownMenuItem(
                    value: rooms,
                    child: Text('$rooms rooms'),
                  ))
              .toList(),
          onChanged: (value) => selectedRooms = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedRooms != null) {
                setState(() => _preferredRooms.add(selectedRooms!));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _minSquareMetersController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
