import 'package:flutter/material.dart';
import 'view.dart';
import 'view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final vm = KanbanViewModel();
  await vm.load();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF0052CC),
      scaffoldBackgroundColor: const Color(0xFFF4F5F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0052CC),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
    ),
    home: KanbanView(vm),
  ));
}
