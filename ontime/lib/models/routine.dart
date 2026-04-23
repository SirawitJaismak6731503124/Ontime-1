import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 0)
class Routine extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late int hour;

  @HiveField(3)
  late int minute;

  /// List of weekday integers: 1=Mon, 2=Tue, ..., 7=Sun
  @HiveField(4)
  late List<int> days;

  @HiveField(5)
  late bool isActive;

  Routine({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.days,
    this.isActive = true,
  });

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get formattedDays {
    const names = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final sorted = List<int>.from(days)..sort();
    return sorted.map((d) => names[d] ?? '').join('  ');
  }

  bool get isEveryDay => days.length == 7;
  bool get isWeekday => days.length == 5 && !days.contains(6) && !days.contains(7);
  bool get isWeekend => days.length == 2 && days.contains(6) && days.contains(7);

  String get daysLabel {
    if (isEveryDay) return 'Every day';
    if (isWeekday) return 'Weekdays';
    if (isWeekend) return 'Weekends';
    return formattedDays;
  }
}
