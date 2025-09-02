import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/app_export.dart';
import '../../core/reminder_model.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    try {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      
      // Request notification permissions for Android 13+
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      print('Notification initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddReminderDialog() {
    _descriptionController.clear();
    _selectedDate = null;
    _selectedTime = null;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setDialogState(() => _selectedDate = date);
                        }
                      },
                      icon: Icon(Icons.calendar_today),
                      label: Text(_selectedDate == null 
                          ? 'Date' 
                          : '${_selectedDate!.day}/${_selectedDate!.month}'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() => _selectedTime = time);
                        }
                      },
                      icon: Icon(Icons.access_time),
                      label: Text(_selectedTime == null 
                          ? 'Time' 
                          : _selectedTime!.format(context)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_descriptionController.text.trim().isNotEmpty) {
                  DateTime? reminderDateTime;
                  if (_selectedDate != null && _selectedTime != null) {
                    reminderDateTime = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                  }
                  
                  final reminder = Reminder(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    description: _descriptionController.text.trim(),
                    reminderDate: reminderDateTime,
                    createdAt: DateTime.now(),
                  );
                  
                  final box = Hive.box<Reminder>('reminders');
                  await box.add(reminder);
                  
                  if (reminderDateTime != null) {
                    _scheduleNotification(reminder);
                  }
                  
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleNotification(Reminder reminder) async {
    if (reminder.reminderDate != null) {
      try {
        await flutterLocalNotificationsPlugin.show(
          reminder.id.hashCode,
          'Reminder',
          reminder.description,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders',
              'Reminders',
              channelDescription: 'Reminder notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      } catch (e) {
        print('Failed to show notification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set notification')),
        );
      }
    }
  }

  void _deleteReminder(Reminder reminder) async {
    await flutterLocalNotificationsPlugin.cancel(reminder.id.hashCode);
    await reminder.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Reminder>('reminders').listenable(),
        builder: (context, Box<Reminder> box, _) {
          final reminders = box.values.toList();
          
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 2.h),
                  Text('No reminders yet'),
                  SizedBox(height: 1.h),
                  Text('Add your first reminder'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                margin: EdgeInsets.only(bottom: 2.h),
                child: ListTile(
                  title: Text(reminder.description),
                  subtitle: reminder.reminderDate != null
                      ? Text('${reminder.reminderDate!.day}/${reminder.reminderDate!.month}/${reminder.reminderDate!.year} at ${TimeOfDay.fromDateTime(reminder.reminderDate!).format(context)}')
                      : Text('No date set'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteReminder(reminder);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}