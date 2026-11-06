import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class KanbanViewModel extends ChangeNotifier {
  final prefs = SharedPreferencesAsync();
  final tasks = <Task>[];

  int get nextNum => tasks.fold(0, (m, t) => t.num > m ? t.num : m) + 1;

  int points(int status) => tasks
      .where((t) => t.status == status)
      .fold(0, (sum, t) => sum + t.points);
  int get totalPoints => tasks.fold(0, (sum, t) => sum + t.points);

  Future<void> load() async {
    final data = await prefs.getString('ptai-jira');
    if (data == null) {
      tasks.addAll([
        Task('ぷよぷよの盤面評価関数を作る', 2, 5, 1),
        Task('テトリスの盤面評価関数を作る', 1, 5, 2),
        Task('連鎖・T-Spinの先読み探索を実装する', 0, 8, 3),
        Task('対戦時の攻撃（おじゃま）量の計算を合わせる', 0, 3, 4),
        Task('AIの強さをレベル1〜5で切り替える', 0, 3, 5),
      ]);
      return;
    }
    tasks.clear();
    for (final t in jsonDecode(data)) {
      tasks.add(Task(t['title'], t['status'], t['points'], t['num']));
    }
  }

  Future<void> save() async {
    notifyListeners();
    final data = [
      for (final t in tasks)
        {'title': t.title, 'status': t.status, 'points': t.points, 'num': t.num}
    ];
    await prefs.setString('ptai-jira', jsonEncode(data));
  }

  void add(String text, int points) {
    tasks.add(Task(text, 0, points, nextNum));
    save();
  }

  void move(Task t, int status) {
    t.status = status;
    save();
  }

  void update(Task t, String text, int points) {
    t.title = text;
    t.points = points;
    save();
  }

  void remove(Task t) {
    tasks.remove(t);
    save();
  }
}
