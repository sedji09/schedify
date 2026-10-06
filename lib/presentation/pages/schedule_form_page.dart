import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/schedule_provider.dart';
import '../../domain/entities/schedule.dart';

class ScheduleFormPage extends StatefulWidget {
  final Schedule? scheduleToEdit;

  const ScheduleFormPage({Key? key, this.scheduleToEdit}) : super(key: key);

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late String _subject;
  late String _professor;
  late String _room;
  late String _notes;
  DayOfWeek? _selectedDay; // Ginawang nullable para pwedeng walang laman sa simula
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Color _selectedColor;

  final List<Color> _availableColors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.yellow, Colors.blue.shade900, Colors.cyan
  ];

  @override
  void initState() {
    super.initState();
    if (widget.scheduleToEdit != null) {
      _subject = widget.scheduleToEdit!.subject;
      _professor = widget.scheduleToEdit!.professor;
      _room = widget.scheduleToEdit!.room;
      _notes = widget.scheduleToEdit!.notes;
      _selectedDay = widget.scheduleToEdit!.day;
      _startTime = widget.scheduleToEdit!.startTime;
      _endTime = widget.scheduleToEdit!.endTime;
      _selectedColor = widget.scheduleToEdit!.color;
    } else {
      _subject = '';
      _professor = '';
      _room = '';
      _notes = '';
      _selectedDay = null; // Gagawing null para lumabas ang hint na "Select Day"
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
      _selectedColor = Colors.blue;
    }
  }

  void _saveSchedule() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day first!')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newSchedule = Schedule(
        id: widget.scheduleToEdit?.id ?? const Uuid().v4(),
        subject: _subject,
        professor: _professor,
        room: _room,
        day: _selectedDay!, // Nilagyan ng ! kasi siguradong may laman na ito dahil sa validator
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        notes: _notes,
      );

      if (widget.scheduleToEdit != null) {
        Provider.of<ScheduleProvider>(context, listen: false).updateSchedule(newSchedule);
      } else {
        Provider.of<ScheduleProvider>(context, listen: false).addSchedule(newSchedule);
      }

      Navigator.pop(context);
    }
  }

  void _deleteSchedule() {
    if (widget.scheduleToEdit != null) {
      Provider.of<ScheduleProvider>(context, listen: false).deleteSchedule(widget.scheduleToEdit!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scheduleToEdit == null ? 'Add Schedule' : 'Edit Schedule'),
        actions: [
          if (widget.scheduleToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSchedule,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _subject,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a subject' : null,
                onSaved: (value) => _subject = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _professor,
                decoration: const InputDecoration(labelText: 'Professor', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a professor' : null,
                onSaved: (value) => _professor = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _room,
                decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a room' : null,
                onSaved: (value) => _room = value!,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<DayOfWeek>(
                    initialSelection: _selectedDay,
                    width: constraints.maxWidth,
                    hintText: 'Select Day',
                    label: const Text('Day'),
                    dropdownMenuEntries: DayOfWeek.values.map((day) {
                      final isSelected = _selectedDay == day;
                      return DropdownMenuEntry(
                        value: day,
                        label: day.name.toUpperCase(),
                        style: isSelected
                            ? MenuItemButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              )
                            : null,
                      );
                    }).toList(),
                    onSelected: (value) {
                      setState(() {
                        _selectedDay = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(_startTime.format(context)),
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: _startTime);
                        if (time != null) setState(() => _startTime = time);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(_endTime.format(context)),
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: _endTime);
                        if (time != null) setState(() => _endTime = time);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8), // Dagdag espasyo sa ilalim ng text
              Wrap(
                spacing: 8.0, // Binawasan ko ang spacing para magkasya lahat
                runSpacing: 8.0, // Spacing kapag bumaba sa second line
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = color);
                    },
                    child: Container(
                      width: 36, // Pinaliit ko ng kaunti (mula 40 naging 36)
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (value) => _notes = value ?? '',
              ),
              const SizedBox(height: 32),
                ElevatedButton(
                onPressed: _saveSchedule,
               style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
