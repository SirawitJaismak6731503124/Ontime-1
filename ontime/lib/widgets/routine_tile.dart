import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineTile extends StatelessWidget {
  final Routine routine;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const RoutineTile({
    super.key,
    required this.routine,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(routine.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.black,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.formattedTime,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: routine.isActive ? Colors.black : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    routine.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: routine.isActive ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    routine.daysLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: routine.isActive ? Colors.grey[500] : Colors.grey[350],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: routine.isActive,
              onChanged: onToggle,
              activeColor: Colors.black,
              activeTrackColor: Colors.grey[300],
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[100],
            ),
          ],
        ),
      ),
    );
  }
}
