import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart' show MyHomePage;
///----main function to run app----///
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(MyApp());
  });
}


/*class ColorTheme{
  Color textColor;
  Color selectionColor;
  ColorTheme(Color color){
    textColor = color;
    selectionColor = color.withOpacity(0.3);
  }
}*/

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blending Board',
      theme: ThemeData(
        fontFamily: 'SF-Pro-Rounded',
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Blending Board'),
      debugShowCheckedModeBanner: false,
    );
  }
}

