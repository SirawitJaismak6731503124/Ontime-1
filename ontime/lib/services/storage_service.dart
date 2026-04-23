import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine.dart';

class StorageService {
  static const _boxName = 'routines';
  late Box<Routine> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RoutineAdapter());
    _box = await Hive.openBox<Routine>(_boxName);
  }

  List<Routine> getAll() {
    return _box.values.toList();
  }

  Future<void> save(Routine routine) async {
    await _box.put(routine.id, routine);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  ValueListenable<Box<Routine>> listenable() => _box.listenable();
}
