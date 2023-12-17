import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';


import '../config/size_config.dart';
import '../config/global_variables.dart';
import '../screen_transitions.dart';
import 'home_screen.dart' show MyHomePage;


///----Blending Board Screen----///
class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  int counter1 = 0;
  int counter2 = 0;
  int counter3 = 0;
  String beginningCardName = letterPackMap[letterPackName].beginning.letters[0];
  String middleCardName = letterPackMap[letterPackName].middle.letters[0];
  String endCardName = letterPackMap[letterPackName].end.letters[0];
  bool isShufflePressed = false;

  Random random = new Random();

  Color checkTextColor(String letter) {
    if (isDarkModeOn == true) {
      return Colors.white;
    } else {
      if (checkVowels(letter) == true) {
        return Color(0xFFb46605);
      } else {
        return Colors.black;
      }
    }
  }

  Color checkBackgroundColor(String letter) {
    Color backgroundColor;
    if (isDarkModeOn) {
      backgroundColor = (Colors.black);
    } else {
      backgroundColor = (Colors.white);
    }
    if (isDarkModeOn && checkVowels(letter)) {
      backgroundColor = Color(0xFF4d4003);
    } else if (!isDarkModeOn && checkVowels(letter)) {
      backgroundColor = Color(0xFFfdf0b1);
    }
    return backgroundColor;
  }

  /*if(checkVowels(letter) == true){
      return Color(0xFFfdf0b1);
    }
    else{
      if(isDarkModeOn == true){
        return(Colors.black);
      }
      else{
        return(Colors.white);
      }
    }*/

  bool checkVowels(String letter) {
    if (letter.toLowerCase() == 'a' ||
        letter.toLowerCase() == 'e' ||
        letter.toLowerCase() == 'i' ||
        letter.toLowerCase() == 'o' ||
        letter.toLowerCase() == 'u') {
      return true;
    } else {
      return false;
    }
  }

  _saveLetterPackName(String stringValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "currentLetterPackName";
    final value = stringValue;
    prefs.setString(key, value);
  }

  String listToStringConverter(List<String> stringList) {
    String stringData = "";
    //convert stringlist to a string
    for (int i = 0; i < stringList.length; i++) {
      stringData += stringList[i];
      //the comma separates each element of QRStringList
      stringData += ",";
    }
    return stringData;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    //save current letter pack name
    _saveLetterPackName(letterPackName);
    //letterPackMap[letterPackName].dataEncode(QRStringList);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                body: Stack(children: [
              Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: currentBackgroundImage, fit: BoxFit.cover)),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: homeButton(),
              ),
              Positioned(
                  top: 5 + SizeConfig.safeAreaVertical,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: (SizeConfig.screenHeight * 0.05),
                    child: IconButton(
                      icon: Icon(SFSymbols.qrcode),
                      iconSize: SizeConfig.screenHeight * 0.05,
                      color: colorsList[colorChipIndex],
                      onPressed: () {
                        print(letterPackMap[letterPackName].dataEncodeiOS());
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  content: Container(
                                width: SizeConfig.screenHeight - 20,
                                height: SizeConfig.screenHeight - 20,
                                child: Center(
                                    child: QrImage(
                                  data: letterPackMap[letterPackName]
                                      .dataEncodeiOS(),
                                  version: QrVersions.auto,
                                  //size: 100,
                                )),
                              ));
                            });
                      },
                    ),
                  )),
              Positioned(
                top: 5 + SizeConfig.safeAreaVertical,
                left: 20,
                child: shuffleButton(),
              ),
              Align(
                alignment: Alignment.center,
                child: cardButtonRow(),
              )
            ]))));
  }

  /// ---- Build Methods for Widgets on Blending Board Screen ----///
  Widget homeButton() {
    return CircleAvatar(
      backgroundColor: Colors.black54,
      radius: (SizeConfig.screenHeight * 0.05),
      child: IconButton(
        icon: Icon(SFSymbols.house_fill),
        iconSize: SizeConfig.screenHeight * 0.05,
        color: colorsList[colorChipIndex], //Color(0xFF0690d4),
        onPressed: () {
          Navigator.push(context, FadeRoute(page: MyHomePage())
              /*MyPopupRoute(
                      builder: (BuildContext context){
                        return MyHomePage();
                      }
                    ),*/
              );

          /*print(isHomePressed);
                  setState(() {
                    isHomePressed = !isHomePressed;
                  });
                  */
        },
      ),
    );
  }

  Widget shuffleButton() {
    return CircleAvatar(
      backgroundColor: isShufflePressed == false
          ? Colors.black54
          : colorsList[colorChipIndex],
      radius: (SizeConfig.screenHeight * 0.05),
      child: IconButton(
        icon: Icon(SFSymbols.shuffle),
        iconSize: SizeConfig.screenHeight * 0.05,
        color: isShufflePressed == false
            ? colorsList[colorChipIndex]
            : Colors
                .black, //isShufflePressed == false ? Color(0xFF0690d4): Color(0xFF000000),
        onPressed: () {
          isShufflePressed = !isShufflePressed;
          if (isShufflePressed == true) {
            //if shuffle is pressed, randomize
            setState(() {
              counter1 = random.nextInt(
                  letterPackMap[letterPackName].beginning.letters.length);
              beginningCardName =
                  letterPackMap[letterPackName].beginning.letters[counter1];
              counter2 = random
                  .nextInt(letterPackMap[letterPackName].middle.letters.length);
              middleCardName =
                  letterPackMap[letterPackName].middle.letters[counter2];
              counter3 = random
                  .nextInt(letterPackMap[letterPackName].end.letters.length);
              endCardName = letterPackMap[letterPackName].end.letters[counter3];
            });
          } else {
            //if shuffle is not pressed, set to original
            setState(() {
              counter1 = 0;
              beginningCardName =
                  letterPackMap[letterPackName].beginning.letters[counter1];
              counter2 = 0;
              middleCardName =
                  letterPackMap[letterPackName].middle.letters[counter2];
              counter3 = 0;
              endCardName = letterPackMap[letterPackName].end.letters[counter3];
            });
          }
        },
      ),
    );
  }

  Widget beginningCardButton() {
    return Container(
        width: SizeConfig.screenWidth * 0.27,
        height: SizeConfig.screenWidth * 0.27,
        margin: EdgeInsets.only(top: 20, right: 5, left: 20, bottom: 20),
        child: ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(
              primary: checkTextColor(beginningCardName),
              backgroundColor: checkBackgroundColor(beginningCardName),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: AutoSizeText(
              beginningCardName,
              maxLines: 1,
              style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 10,
                  fontFamily: "DidactGothic",
                  fontWeight: FontWeight.w400),
            ),

            //color: checkVowels(beginningCardName) ? Color(0xFFfdf0b1) : Colors.white,
            //textColor: checkVowels(beginningCardName) ? Color(0xFFb46605) : Colors.black,

            onPressed: () {
              setState(() {
                counter1++;
                if (counter1 >=
                    letterPackMap[letterPackName].beginning.letters.length) {
                  counter1 = 0;
                }
                beginningCardName =
                    letterPackMap[letterPackName].beginning.letters[counter1];
              });
            },
          ),
        ));
  }

  Widget beginningCardBackground() {
    return Container(
        width: SizeConfig.screenWidth * 0.27,
        height: SizeConfig.screenWidth * 0.27,
        margin: EdgeInsets.only(top: 20, right: 5, left: 20, bottom: 20),
        decoration: BoxDecoration(
            color: isDarkModeOn ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10)));
  }

  Widget middleCardButton() {
    return Container(
        width: SizeConfig.screenWidth * 0.27,
        height: SizeConfig.screenWidth * 0.27,
        margin: EdgeInsets.only(top: 20, right: 5, left: 5, bottom: 20),
        child: ButtonTheme(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: checkBackgroundColor(middleCardName),
              primary: checkTextColor(middleCardName),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: AutoSizeText(
              middleCardName,
              maxLines: 1,
              //minFontSize: 25.0,
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 10,
                fontFamily: "DidactGothic",
                fontWeight: FontWeight.w400,
              ),
            ),
            onPressed: () {
              setState(() {
                counter2++;
                if (counter2 >=
                    letterPackMap[letterPackName].middle.letters.length) {
                  counter2 = 0;
                }
                middleCardName =
                    letterPackMap[letterPackName].middle.letters[counter2];
              });
            },
          ),
        ));
  }

  Widget middleCardBackground() {
    return Container(
        width: SizeConfig.screenWidth * 0.27,
        height: SizeConfig.screenWidth * 0.27,
        margin: EdgeInsets.only(top: 20, right: 5, left: 5, bottom: 20),
        decoration: BoxDecoration(
            color: checkBackgroundColor(middleCardName),
            borderRadius: BorderRadius.circular(10)));
  }

  Widget endCardButton() {
    return Container(
      width: SizeConfig.screenWidth * 0.27,
      height: SizeConfig.screenWidth * 0.27,
      margin: EdgeInsets.only(top: 20, right: 20, left: 5, bottom: 20),
      child: ButtonTheme(
          child: TextButton(
        style: TextButton.styleFrom(
          primary: checkTextColor(endCardName),
          backgroundColor: checkBackgroundColor(endCardName),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: AutoSizeText(
          endCardName,
          maxLines: 1,
          style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 10,
              fontFamily: "DidactGothic",
              fontWeight: FontWeight.w400),
        ),
        onPressed: () {
          setState(() {
            counter3++;
            if (counter3 >= letterPackMap[letterPackName].end.letters.length) {
              counter3 = 0;
            }
            endCardName = letterPackMap[letterPackName].end.letters[counter3];
          });
        },
      )),
    );
  }

  Widget endCardBackground() {
    return Container(
        width: SizeConfig.screenWidth * 0.27,
        height: SizeConfig.screenWidth * 0.27,
        margin: EdgeInsets.only(top: 20, right: 20, left: 5, bottom: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)));
  }

  Widget cardButtonRow() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        beginningCardButton(),
        middleCardButton(),
        endCardButton(),
      ],
    ));
  }

  Widget cardBackgroundRow() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        beginningCardBackground(),
        middleCardBackground(),
        endCardBackground(),
      ],
    ));
  }
}