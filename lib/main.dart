import 'package:bite_box/firebase_options.dart';
import 'package:bite_box/provider/google_sign_in.dart';
import 'package:bite_box/screens/Admin/adminhome.dart';
import 'package:bite_box/screens/loginpage.dart';
import 'package:bite_box/screens/signup.dart';
import 'package:bite_box/screens/user/user_home.dart';
import 'package:bite_box/utils/checkuser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        '/AdminHome/': (context) => const AdminHome(),
        '/UserHome/': (context) => const User_home(initialSelectedIndex: 0),
      },
    );
  }
}
