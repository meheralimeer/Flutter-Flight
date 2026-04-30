import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meeting.dart';
import '../constants/app_constants.dart';

class MeetingForm extends StatefulWidget {
  final Meeting? meeting;
  final List<String> teamIds;
  final Function({
    required String teamId,
    required String topic,
    required DateTime scheduledAt,
    String? location,
    String? notes,
  })
  onSubmit;
  final VoidCallback? onCancel;

  const MeetingForm({
    super.key,
    this.meeting,
    required this.teamIds,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<MeetingForm> createState() => _MeetingFormState();
}

class _MeetingFormState extends State<MeetingForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _topicController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  String? _selectedTeamId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.meeting?.topic ?? '');
    _locationController = TextEditingController(
      text: widget.meeting?.location ?? '',
    );
    _notesController = TextEditingController(text: widget.meeting?.notes ?? '');
    _selectedTeamId =
        widget.meeting?.teamId ??
        (widget.teamIds.isNotEmpty ? widget.teamIds.first : null);
    if (widget.meeting != null) {
      _selectedDate = widget.meeting!.scheduledAt;
      _selectedTime = TimeOfDay.fromDateTime(widget.meeting!.scheduledAt);
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedTeamId,
              decoration: const InputDecoration(
                labelText: 'Team',
                prefixIcon: Icon(Icons.group),
                border: OutlineInputBorder(),
              ),
              items: widget.teamIds
                  .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedTeamId = value),
              validator: (value) =>
                  value == null ? 'Please select a team' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                prefixIcon: Icon(Icons.topic),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a topic' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(DateFormat('EEEE, MMM d, y').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                child: Text(_selectedTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.meeting == null ? 'Create' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      widget.onSubmit(
        teamId: _selectedTeamId!,
        topic: _topicController.text,
        scheduledAt: scheduledAt,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
    }
  }
}
