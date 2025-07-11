import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_service.dart';
import 'notification_service.dart';
import 'ui/home_screen.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await notificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskService(notificationService: notificationService),
      child: MaterialApp(
        title: 'Functional Focus',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.transparent,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.purple.shade300,
            foregroundColor: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.white70),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) => 
                states.contains(MaterialState.selected) ? Colors.purple.shade300 : Colors.grey),
            trackColor: MaterialStateProperty.resolveWith((states) => 
                states.contains(MaterialState.selected) ? Colors.purple.withOpacity(0.5) : Colors.grey.withOpacity(0.5)),
          )
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}