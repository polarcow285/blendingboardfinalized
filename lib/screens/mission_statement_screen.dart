import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/size_config.dart';
import 'package:url_launcher/url_launcher.dart';


class MissionStatementScreen extends StatefulWidget {
  @override
  _MissionStatementScreenState createState() => _MissionStatementScreenState();
}

/**
 * Screen where users can learn more about the app's mission statement.
 */
class _MissionStatementScreenState extends State<MissionStatementScreen> {

  /**
   * Upon initialization, the screen is set to landscape mode.
   */
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  /**
   * Url of the dyslexic mindset website
   */
  final Uri _url = Uri.parse('http://dyslexicmindset.weebly.com/');

  /**
   * Launches the url
   */
  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  /**
   * Returns the main components of the Mission Statement Screen.
   */
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: Stack(
          //alignment: Alignment.center,
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/water-blue-ocean.jpg"),
                      fit: BoxFit.cover)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: ,
              children: <Widget>[
                Flexible(
                  child: missionStatementImage(),
                ),
                missionStatementText()
              ],
            ),
            Positioned(
              top: SizeConfig.safeAreaVertical + 10,
              left: 20,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel),
                  iconSize: SizeConfig.screenHeight * 0.05,
                  color: Colors.white),
            )
          ],
        )));
  }

  ///----Build methods for Mission Statement Screen----///
  /**
   * Returns a GestureDetector in the form of the Dyslexic Mindset brain image that launches the 
   * website url when tapped.
   */
  Widget missionStatementImage() {
    return GestureDetector(
      onTap: () {
        _launchUrl();
      },
      child: Image(
        image: AssetImage('assets/dyslexiaBrain.png'),
        height: SizeConfig.screenWidth * 0.9,
        width: SizeConfig.screenHeight * 0.9,
      ),
    );
  }

  /**
   * Returns the text of the app's mission statement.
   */
  Widget missionStatementText() {
    return Container(
        margin: EdgeInsets.all(SizeConfig.safeAreaVertical + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Mission:",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.safeBlockHorizontal * 2.5),
            ),
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: SizeConfig.screenHeight / 1.5,
                  maxHeight: SizeConfig.screenWidth,
                ),
                child: Text(
                  "\nThis app was created to ensure access to FREE dyslexia resources as part of Nadine Gilkison's Google Innovator Project.\nSpecial thanks to Brayden Gogis for creating this app to help millions of teachers and students on a global scale.\nTap the brain for more FREE resources!",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: SizeConfig.safeBlockHorizontal * 2),
                ))
          ],
        ));
  }
}