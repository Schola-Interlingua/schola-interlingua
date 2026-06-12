import 'package:flutter/widgets.dart';

import 'src/app_state.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppController controller = AppController();
  await controller.initialize();
  await controller.loadVocab();
  runApp(ScholaInterlinguaApp(controller: controller));
}
