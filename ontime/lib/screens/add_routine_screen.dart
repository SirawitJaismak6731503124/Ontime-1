import 'package:flutter/material.dart';
import '../models/routine.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AddRoutineScreen extends StatefulWidget {
  final StorageService storage;
  final NotificationService notifications;

  const AddRoutineScreen({
    super.key,
    required this.storage,
    required this.notifications,
  });

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Mon–Fri default
  bool _saving = false;

  static const _days = [
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final routine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      days: _selectedDays.toList(),
    );

    await widget.storage.save(routine);
    await widget.notifications.scheduleRoutine(routine);

    if (mounted) Navigator.pop(context);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Routine',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _saving ? Colors.grey[400] : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('Title'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Morning run',
                hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
            _SectionLabel('Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _formatTime(_selectedTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _SectionLabel('Repeat'),
            const SizedBox(height: 12),
            _QuickSelect(
              selectedDays: _selectedDays,
              onSelect: (days) => setState(() {
                _selectedDays.clear();
                _selectedDays.addAll(days);
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: _days.map((d) {
                final (num, label) = d;
                final selected = _selectedDays.contains(num);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedDays.remove(num);
                        } else {
                          _selectedDays.add(num);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.black : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? Colors.black : Colors.grey[200]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.grey[500],
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.grey[400],
      ),
    );
  }
}

class _QuickSelect extends StatelessWidget {
  final Set<int> selectedDays;
  final void Function(List<int>) onSelect;

  const _QuickSelect({required this.selectedDays, required this.onSelect});

  bool _matches(List<int> preset) {
    if (selectedDays.length != preset.length) return false;
    return preset.every((d) => selectedDays.contains(d));
  }

  @override
  Widget build(BuildContext context) {
    final presets = [
      ('Every day', [1, 2, 3, 4, 5, 6, 7]),
      ('Weekdays', [1, 2, 3, 4, 5]),
      ('Weekends', [6, 7]),
    ];

    return Row(
      children: presets.map((p) {
        final (label, days) = p;
        final active = _matches(days);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(days),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? Colors.black : Colors.grey[300]!,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
