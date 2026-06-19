import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app_state.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://redvymknnxehwveyzmyw.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlZHZ5bWtubnhlaHd2ZXl6bXl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwNzM5NTMsImV4cCI6MjA4MTY0OTk1M30.XcdT2RYq5tKFZziLkOO6mcQZzAUHMJf5ORzkZa2-La8',
  );
  final AppController controller = AppController();
  await controller.initialize();
  await controller.loadVocab();
  runApp(ScholaInterlinguaApp(controller: controller));
}
