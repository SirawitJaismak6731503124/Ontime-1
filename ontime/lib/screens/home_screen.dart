import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/routine_tile.dart';
import 'add_routine_screen.dart';

class HomeScreen extends StatelessWidget {
  final StorageService storage;
  final NotificationService notifications;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            Expanded(child: _RoutineList(storage: storage, notifications: notifications)),
          ],
        ),
      ),
      floatingActionButton: _AddButton(storage: storage, notifications: notifications),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ontime',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your daily routines',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey[200]),
        ],
      ),
    );
  }
}

class _RoutineList extends StatelessWidget {
  final StorageService storage;
  final NotificationService notifications;

  const _RoutineList({required this.storage, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Routine>>(
      valueListenable: storage.listenable(),
      builder: (context, box, _) {
        final routines = box.values.toList()
          ..sort((a, b) {
            final aMin = a.hour * 60 + a.minute;
            final bMin = b.hour * 60 + b.minute;
            return aMin.compareTo(bMin);
          });

        if (routines.isEmpty) {
          return _EmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: routines.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, indent: 24, endIndent: 24, color: Colors.grey[100]),
          itemBuilder: (context, index) {
            final routine = routines[index];
            return RoutineTile(
              routine: routine,
              onToggle: (val) async {
                routine.isActive = val;
                await storage.save(routine);
                if (val) {
                  await notifications.scheduleRoutine(routine);
                } else {
                  await notifications.cancelRoutine(routine.id);
                }
              },
              onDelete: () async {
                await notifications.cancelRoutine(routine.id);
                await storage.delete(routine.id);
              },
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No routines yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first routine',
            style: TextStyle(fontSize: 13, color: Colors.grey[350]),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final StorageService storage;
  final NotificationService notifications;

  const _AddButton({required this.storage, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const CircleBorder(),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddRoutineScreen(
              storage: storage,
              notifications: notifications,
            ),
          ),
        );
      },
      child: const Icon(Icons.add, size: 28),
    );
  }
}
