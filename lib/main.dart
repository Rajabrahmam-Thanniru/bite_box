import 'package:bite_box/firebase_options.dart';
import 'package:bite_box/provider/google_sign_in.dart';
import 'package:bite_box/screens/Admin/adminhome.dart';
import 'package:bite_box/screens/loginpage.dart';
import 'package:bite_box/screens/signup.dart';
import 'package:bite_box/screens/user/user_home.dart';
import 'package:bite_box/utils/checkuser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'bitebox_notifications_channel',
    'bitebox',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'Default Title',
    message.notification?.body ?? 'Default Body',
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    _showNotification(message);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bite Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/CheckUser/',
      routes: {
        "/CheckUser/": (context) => const CheckUser(),
        '/LoginPage/': (context) => const LoginPage(),
        '/Signup/': (context) => const SignUp(),
        '/AdminHome/': (context) => const AdminHome(initialSelectedIndex: 0),
        '/UserHome/': (context) => const User_home(initialSelectedIndex: 0),
      },
    );
  }
}
