import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/size_config.dart';
import '../config/global_variables.dart';
import '../screen_transitions.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'dart:ui';


import 'home_screen.dart' show MyHomePage;
import 'board_screen.dart' show BoardScreen;
///----My Decks Screen----///

class MyDecksScreen extends StatefulWidget {
  @override
  _MyDecksScreenState createState() => _MyDecksScreenState();
}

class _MyDecksScreenState extends State<MyDecksScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    //final double itemHeight = (size.height - kToolbarHeight - 24) / 2;

    final double itemWidth = SizeConfig.screenWidth;
    final double itemHeight = itemWidth / 5;

    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
            theme: ThemeData(
              fontFamily: 'SF-Pro-Rounded',
            ),
            debugShowCheckedModeBanner: false,
            home: Stack(
              children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: currentBackgroundImage, fit: BoxFit.cover)),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkModeOn
                                ? Colors.black.withOpacity(0.65)
                                : Colors.black.withOpacity(0.4),
                          ),
                        ))),
                Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Stack(alignment: Alignment.center, children: <Widget>[
                      Positioned(
                        top: 20,
                        child: myDecksColumn(itemWidth, itemHeight),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              //FadeSlideRightRoute(page: MyApp()),
                              MaterialPageRoute(builder: (context) => MyHomePage()),
                            );
                          },
                          icon: Icon(SFSymbols.house_fill),
                          iconSize: SizeConfig.screenHeight * 0.05,
                          color: colorsList[colorChipIndex], //Color(0xFF0690d4)
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        "Are you sure you want to clear all decks?",
                                        textAlign: TextAlign.center),
                                    content: Container(
                                        width: SizeConfig.screenWidth * 0.3,
                                        height: SizeConfig.screenWidth * 0.3,
                                        child: Center(
                                          child: Text(
                                              "All decks will be deleted except for the default decks.",
                                              textAlign: TextAlign.center),
                                        )),
                                    actions: <Widget>[
                                      TextButton(
                                          child: Text("NO"),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop(context);
                                          }),
                                      TextButton(
                                          child: Text("YES"),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop(context);
                                            reset();
                                            firstBuild = true;
                                            Navigator.push(
                                              context,
                                              FadeRoute(page: MyHomePage()),
                                            );
                                          }),
                                    ],
                                  );
                                });
                          },
                          icon: Icon(SFSymbols.trash_fill),
                          iconSize: SizeConfig.screenHeight * 0.05,
                          color: colorsList[colorChipIndex], //Color(0xFF0690d4)
                        ),
                      ),
                    ]))
              ],
            )));
  }

  ///----Build methods for My Decks Screen----///

  Widget myDecksColumn(double width, double height) {
    return Container(
        margin: EdgeInsets.only(top: SizeConfig.safeBlockHorizontal),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text("My Decks",
                  style: TextStyle(
                    color: colorsList[colorChipIndex],
                    fontWeight: FontWeight.w500,
                    fontSize: SizeConfig.safeBlockHorizontal * 2.5,
                  )),
            ),
            gridView(width, height),
          ],
        ));
  }

  Widget gridView(double width, double height) {
    return ConstrainedBox(
      constraints: new BoxConstraints(
          maxHeight: SizeConfig.screenWidth,
          maxWidth: SizeConfig.screenWidth - SizeConfig.safeAreaVertical),
      child: GridView.count(
        // Create a grid with 3 columns. If you change the scrollDirection to
        // horizontal, this produces 3 rows.
        crossAxisCount: 3,
        childAspectRatio: (width / height),
        // Generate allPacks.length amount widgets that display their index in the List.
        children: List.generate(allPacks.length, (index) {
          //left deck
          if (index % 3 == 0) {
            return Container(
              margin: EdgeInsets.only(
                  top: 5,
                  right: 5,
                  left: SizeConfig.safeAreaVertical + 30,
                  bottom: 5),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: currentColor,
                  backgroundColor: isDarkModeOn ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(allPacks[index].name,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 2,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                ),
                onPressed: () {
                  letterPackName = allPacks[index].name;
                  Navigator.push(
                    context,
                    FadeRoute(page: BoardScreen()),
                  );
                },
              ),
            );
          }
          //right deck
          else if ((index - 2) % 3 == 0) {
            return Container(
              margin: EdgeInsets.only(
                  top: 5,
                  right: SizeConfig.safeAreaVertical + 30,
                  left: 5,
                  bottom: 5),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: currentColor, //Color(0xFF0342dc),
                  backgroundColor: isDarkModeOn ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(allPacks[index].name,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 2,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                ),
                onPressed: () {
                  letterPackName = allPacks[index].name;
                  Navigator.push(
                    context,
                    FadeRoute(page: BoardScreen()),
                  );
                },
              ),
            );
          }
          //middle deck
          else {
            return Container(
              //width: width,
              //height: height,
              margin: EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 5),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: currentColor,
                  backgroundColor: isDarkModeOn ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(allPacks[index].name,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 2,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                ),
                onPressed: () {
                  letterPackName = allPacks[index].name;
                  Navigator.push(
                    context,
                    FadeRoute(page: BoardScreen()),
                  );
                },
              ),
            );
          }
        }),
      ),
    );
  }
}