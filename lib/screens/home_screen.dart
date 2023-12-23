
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:ui';
import 'package:flutter/services.dart';


import '../config/global_variables.dart';
import '../config/size_config.dart';
import '../letter_pack.dart';
import '../letter_set.dart';
import '../screen_transitions.dart';

import 'mission_statement_screen.dart' show MissionStatementScreen;
import 'board_screen.dart' show BoardScreen;
import 'my_decks_screen.dart' show MyDecksScreen;
import 'create_decks_screen.dart' show CreateDecksScreen;
import 'settings_screen.dart' show SettingsScreen;
import 'save_screen.dart' show SaveScreenState;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/**
 * Home screen of the Blending Board App. 
 */
class _MyHomePageState extends State<MyHomePage> {
  /**
   * String holding the encoded data in a scanned QR code.
   */
  String qrString = "";

  /**
   * Holds the encoded name of the beginning letter set of the scanned letter pack.
   */
  String beginningName = "";

  /**
   * Holds the encoded name of the middle letter set of the scanned letter pack.
   */
  String middleName = "";

  /**
   * Holds the encoded name of the end letter set of the scanned letter pack.
   */
  String endName = "";

  /**
   * Holds the remaining encoded data of the beginning letter set from the scanned letter pack.
   */
  String beginningSubstring = "";

  /**
   * Holds the remaining encoded data of the end letter set from the scanned letter pack.
   */
  String endSubstring = "";

  
  /**
   * Holds the encoded data of the letter pack name from the scanned letter pack.
   */
  String letterPackSubstring = "";

  /**
   * Holds the remaining data of the middle letter set from the scanned letter pack.
   */
  String middleSubstring = "";

  /**
   * Holds the name of the scanned letter pack.
   */
  String lpName = "";

  ///----Reading and Writing to Preferences----///
  
  /**
   * Returns the value stored at the key `keyNumberString`
   */
  Future<List> _read(String keyNumberString) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyNumberString;
    final value = prefs.getStringList(key) ?? [];
    //print('read: $value');
    return value;
  }

  /**
   * Returns a list of Strings with the data encoded for the discard Pack 
   * stored at the key `discardKey`
   */
  Future<List> _readDiscardPack(String discardKey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = discardKey;
    final value = prefs.getStringList(key);
    //print(value);
    return value;
  }

  /**
   * Returns an integer stored at the key `key`.
   */
  Future<int> _readInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    int intValue = prefs.getInt(key);
    return intValue;
  }

  /**
   * Returns the mode stored at the key "currentMode".
   */
  Future<int> _readMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    int intValue = prefs.getInt("currentMode");
    return intValue;
  }

  /**
   * Returns the index of the color theme at the key "colorIndexKey"
   */
  Future<int> _readColorIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    int intValue = prefs.getInt("colorIndexKey");
    return intValue;
  }

  /**
   * Reads the data for all the letter packs, the color theme, and the mode.
   */
  void readAll() async {
    await _readInt("numberOfKeys").then((value) {
      numberOfLetterPacks = value;
    });
    print(numberOfLetterPacks);
    if (numberOfLetterPacks == null) {
      setState(() {
        allPacks.clear();
        allPacks.add(defaultPacks[0]);
        allPacks.add(defaultPacks[1]);
        allPacks.add(defaultPacks[2]);
        numberOfLetterPacks = 3;
      });
      //print("First time. Default packs will be set");
    } else {
      numberOfLetterPacks = numberOfLetterPacks;
      allPacks.clear();

      for (int i = 0; i < numberOfLetterPacks; i++) {
        await _read("$i").then((value) {
          //print(value);
          LetterPack tempPack = LetterPack.decodeLetterPack(value);

          allPacks.add(tempPack);
          //adding pack to letterPackMap
          letterPackMap[value[0]] = tempPack;
        });
      }
      print("Read and decoded all packs");
    }
    print(numberOfLetterPacks);
    await _readMode().then((value) {
      if (value == null) {
        currentMode = auto;
      } else {
        currentMode = value;
      }
    });
    //print(isDarkModeOn);

    await _readColorIndex().then((value) {
      print("value = $value");
      if (value == null) {
        value = 0;
        colorChipIndex = value;
        currentColor = blueC;
        currentBackgroundImage = blueBackgroundImage;
      } else {
        colorChipIndex = value;
        currentColor = themeColorsList[value];
        currentBackgroundImage = backgroundImagesList[value];
        currentBrainLogoImage = brainLogoImagesList[value];
      }
    });
  }


  /**
   * Returns the letter pack name stored at key `key`.
   */
  Future<String> _readLetterPackName(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString(key);
    return stringValue;
  }

  /**
   * Reads the name last opened letter pack. If it is the app's very first time getting opened, it is set
   * to Standard (Closed Syllable) letter pack.
   */
  Future<void> readAtLogoButton() async {
    await _readLetterPackName("currentLetterPackName").then((value) {
      if (value == null) {
        print("First time, letterPackName = null");
        value = "Standard (Closed Syllable)";
      }
      letterPackName = value;
      print(letterPackName);
    });
    if (letterPackName == "discardPack") {
      print("Last pack was a discard Pack, need to load discardPack");
      await _readDiscardPack("discardPackKey").then((value) {
        discardPack = LetterPack.decodeLetterPack(value);
        //adding pack to letterPackMap
        letterPackMap["discardPack"] = discardPack;
      });
    }
  }

  ///---QR Functions----///
  /**
   * Parses the beginning letter set data from qrString.
   */
  void getBeginningSubstring() {
    print(qrString.indexOf("},"));
    beginningSubstring = qrString.substring(1, qrString.indexOf("},"));
    print("beginning substring: " + beginningSubstring);
    qrString =
        qrString.substring(qrString.indexOf("},") + 2, qrString.length - 1);
    print("qr string: " + qrString);
  }

  /**
   * Parses the end letter set data from qrString.
   */
  void getEndSubstring() {
    //print(qrString.indexOf("\"end\""));
    endSubstring = qrString.substring(0, qrString.indexOf("},"));
    print("end substring: " + endSubstring);
    qrString = qrString.substring(qrString.indexOf("},") + 2, qrString.length);
  }

  /**
   * Parses the letter pack name from qrString.
   */
  void getLetterPackSubstring() {
    letterPackSubstring = qrString.substring(
        qrString.indexOf("\"name\""), qrString.indexOf("\"middle\""));

    qrString =
        qrString.substring(qrString.indexOf("\"middle\""), qrString.length);
  }

  /**
   * Parses the middle letter set data from qrString.
   */
  void getMiddleSubstring() {
    middleSubstring = qrString.substring(0, qrString.indexOf("}"));
  }

  /**
   * Parses data from qrString.
   */
  void divideSubstring() {   
    getBeginningSubstring();
    getEndSubstring();
    getLetterPackSubstring();
    getMiddleSubstring();
  }

  /**
   * Returns a letter set by decoding the data in `setSubstring`
   */
  LetterSet stringToLetterSetConverter(String setSubstring) {
    LetterSet tempLS;
    String lsName = "";
    int positionInt = 0;

    setSubstring = setSubstring.replaceAll("\"", "");
    print(setSubstring);
    //there are 5 characters in "name:"
    lsName = setSubstring.substring(
        setSubstring.indexOf("name:") + 5, setSubstring.indexOf(","));
    positionInt = int.parse(setSubstring.substring(
        setSubstring.indexOf("position:") + 9,
        setSubstring.indexOf(",letters")));

    List<String> lettersList = setSubstring
        .substring(setSubstring.indexOf("[") + 1, setSubstring.indexOf("]"))
        .split(',')
        .toList();
    tempLS = LetterSet(lsName, positionInt, lettersList);
    return tempLS;
  }

  /**
   * Returns a LetterPack from  the qr data. 
   */
  LetterPack qrToLetterPack() {
    LetterSet begLS;
    LetterSet midLS;
    LetterSet endLS;
    LetterPack tempLP;
    divideSubstring();
    print("divide substring worked!");
    begLS = stringToLetterSetConverter(beginningSubstring);
    print("beginning worked");
    midLS = stringToLetterSetConverter(middleSubstring);
    print("middle worked");
    endLS = stringToLetterSetConverter(endSubstring);
    print("end worked");
    letterPackSubstring = letterPackSubstring.replaceAll("\"", "");
    lpName = letterPackSubstring.substring(
        letterPackSubstring.indexOf("name:") + 5,
        letterPackSubstring.indexOf(","));

    tempLP = LetterPack(lpName, begLS, midLS, endLS);
    return tempLP;
  }

  /**
   * Encodes the data from the scanned qrcode into a letter pack and opens that letterpack
   * in Board Screen. If an error is thrown, displays a dialog telling the user that QR scanning is not
   * supported on this device.
   */
  Future<void> _scan() async {
    try {
      ScanResult codeSanner = await BarcodeScanner.scan(
        options: ScanOptions(
          useCamera: -1,
        ),
      );
      setState(() {
        //print("{\"beginning\":{\"name\":\"Beginning Blends\",\"position\":1,\"letters\":[\"bl\",\"br\",\"cl\",\"cr\",\"dr\",\"fl\",\"fr\",\"gl\",\"gr\",\"pl\",\"pr\",\"sc\",\"scr\",\"shr\",\"sk\",\"sl\",\"sm\",\"sn\",\"sp\",\"spl\",\"spr\",\"squ\",\"st\",\"str\",\"sw\",\"thr\",\"tr\",\"tw\"]},\"end\":{\"name\":\"Ending Blends\",\"position\":4,\"letters\":[\"sk\",\"sp\",\"st\",\"ct\",\"ft\",\"lk\",\"lt\",\"mp\",\"nch\",\"nd\",\"nt\",\"pt\"]},\"name\":\"Meld did Did Ke\",\"middle\":{\"name\":\"Open Syllable\",\"position\":2,\"letters\":[\"a\",\"e\",\"i\",\"o\",\"u\"]}}");
        qrString = codeSanner.rawContent;
        //print(qrString);
        LetterPack tempLP = qrToLetterPack();
        allPacks.add(tempLP);
        letterPackName = tempLP.name;
        //put new letterPack into letterPackMap
        letterPackMap[allPacks.last.name] = allPacks.last;
        SaveScreenState.saveAll();
        Navigator.push(
          context,
          FadeRoute(page: BoardScreen()),
        );
      });
    } /*on FormatException {
      setState(() {
        Navigator.push(
          context,
          FadeRoute(page: MyHomePage()),
        );
      });
    } */
    catch (e) {
      print("$e");
      String os = Platform.operatingSystem;
      print(os);
      if (os == "windows") {
        print('is a Windows');
        setState(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("QR Scanning Not Supported",
                    textAlign: TextAlign.center),
                content: Container(
                    width: SizeConfig.screenWidth * 0.3,
                    height: SizeConfig.screenWidth * 0.3,
                    child: Center(
                      child: Text(
                          "Unfortunately, Windows devices do not support the ability to scan Blending Board QR codes.",
                          textAlign: TextAlign.center),
                    )),
              );
            },
            barrierDismissible: true,
          );
        });
      } else {
        setState(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Not a Blending Board Deck",
                    textAlign: TextAlign.center),
                content: Container(
                    width: SizeConfig.screenWidth * 0.3,
                    height: SizeConfig.screenWidth * 0.3,
                    child: Center(
                      child: Text(
                          "This code contains the data: $qrString, and is not a Blending Board Deck.",
                          textAlign: TextAlign.center),
                    )),
              );
            },
            barrierDismissible: true,
          );
        });
      }
    }
  }
  /**
   * Checks if the user has granted camera permissions. If the user has, then the user can use their 
   * device's camera to scan the qr code. If the user has not, then displays a dialog asking whether the 
   * app can use device's camera.
   */
  checkCameraPermissions() async {
    var cameraStatus = await Permission.camera.status;
    print(cameraStatus);
    //cameraStatus.isDenied;
    //if camera is not available -> dialog
    //if(cameraStatus.is)
    if (cameraStatus.isGranted) {
      _scan();
    } else {
      //print("igot here");
      //haven't asked for permission yet -> ask for permissions
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Blending Board Would Like to Access the Camera",
                  textAlign: TextAlign.center),
              content: Container(
                  width: SizeConfig.screenWidth * 0.15,
                  height: SizeConfig.screenWidth * 0.15,
                  child: Center(
                    child: Text(
                        "The camera is only used for scanning QR codes of decks",
                        textAlign: TextAlign.center),
                  )),
              actions: <Widget>[
                TextButton(
                    child: Text("Don't Allow"),
                    //set status to denied

                    onPressed: () {
                      //Permission.camera.
                      //cameraStatus.isDenied;
                      Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text("Allow"),
                    onPressed: () async {
                      await Permission.camera.request();
                      Navigator.of(context).pop();
                      _scan();
                    }),
              ],
            );
          },
          barrierDismissible: false,
        );
      });
    }
  }
  /**
   * Upon initialization, the screen is set to landscape mode. If is the first time opening the app,
   * then data is loaded.
   */
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    if (firstBuild == true) {
      reset();
      readAll();
      //print(colorChipIndex);
      //var brightness = SchedulerBinding.instance.window.platformBrightness;
      //print(isDarkModeOn);
      firstBuild = false;
      //currentMode = 2;
      currentColor = themeColorsList[colorChipIndex];
      currentBackgroundImage = backgroundImagesList[colorChipIndex];
      currentBrainLogoImage = brainLogoImagesList[colorChipIndex];
      //colorChipIndex = 0;
    }
  }

  /**
   * Returns the main components of the Home screen.
   */
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (MediaQuery.of(context).size.height > 600) {
      isLargeScreen = true;
    } else {
      isLargeScreen = false;
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    if (currentMode == auto) {
      isDarkModeOn = brightness == Brightness.dark;
    } else if (currentMode == light) {
      isDarkModeOn = false;
    } else {
      isDarkModeOn = true;
    }
    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
            theme: ThemeData(
              fontFamily: 'SF-Pro-Rounded',
            ),
            debugShowCheckedModeBanner: false,
            home: Stack(
              children: <Widget>[
                Container(
                  height: SizeConfig.screenHeight,
                  width: SizeConfig.screenWidth,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: currentBackgroundImage, fit: BoxFit.cover)),
                ),
                Container(
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkModeOn
                                ? Colors.black.withOpacity(0.65)
                                : Colors.black.withOpacity(0.4),
                          ),
                        ))),
                /*Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/water-blue-ocean.jpg"), 
                fit: BoxFit.cover
            )
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                ),
              )
            )
        ),*/
                Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: miscButtonRow(),
                        ),
                        Align(
                          child: mainButtonRow(),
                          alignment: Alignment.center,
                        ),
                        /*Positioned(
                bottom: 20,
                left: 20,
                    child: IconButton(
                      icon: Icon(Icons.palette),
                        color: Color(0xFF0690d4),
                        onPressed: () {
                          _reset();
                          /*Navigator.push(
                            context,
                            SlideRightRoute(page: Test1Screen()),
                          );*/
                        },
                )
              )*/
                        /*Positioned(
                bottom: 20,
                left: 20,
                    child: Text("Version 1.0")
              )*/
                      ],
                    ))
              ],
            )));
  }

  ///----Build methods for widgets in homescreen----///
  /**
   * Returns a button with the createDecksButton, logoButton, and myDecksButton.
   */
  Widget mainButtonRow() {
    return Container(
        child: Row(
      //crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [createDeckButton(), logoButton(), myDecksButton()],
    ));
  }

  /**
   * Returns a row containing the misc butotns.
   */
  Widget miscButtonRow() {
    return Container(
        margin: EdgeInsets.only(top: 5, bottom: SizeConfig.safeAreaVertical),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            missionStatementButton(),
            settingsButton(),
            qrCamera(),
          ],
        ));
  }

  /**
   * Returns a button that leads users to the Create Decks Screen.
   */
  Widget createDeckButton() {
    return Container(
        margin: EdgeInsets.only(
          top: 20,
          right: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(SFSymbols.plus_square_fill),
                color: Colors.white,
                iconSize: (isLargeScreen == true)
                    ? SizeConfig.screenHeight * 0.20
                    : SizeConfig.screenHeight * 0.35, //125,
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideRightRoute(page: CreateDecksScreen()),
                  );
                }),
            Text(
              "Create Deck",
              style: TextStyle(
                color: colorsList[colorChipIndex],
                fontFamily: 'SF-Pro-Rounded',
                fontWeight: FontWeight.w600,
                fontSize: (isLargeScreen == true)
                    ? SizeConfig.safeBlockVertical * 3
                    : SizeConfig.safeBlockVertical * 4,
              ),
            )
          ],
        ));
  }

  /**
   * Returns a button in the shape of the Blending Board logo that leads users
   * to Blending Board screen with the most recent deck used opened.
   */
  Widget logoButton() {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 5, left: 5, bottom: 20),
      child: GestureDetector(
        child: Image(
          image: AssetImage('assets/blendingBoardLogo.png'),
          height: (isLargeScreen == true)
              ? SizeConfig.screenHeight * 0.50
              : SizeConfig.screenHeight * 0.65,
          width: (isLargeScreen == true)
              ? SizeConfig.screenHeight * 0.50
              : SizeConfig.screenHeight * 0.65,
        ),
        onTap: () async {
          //read
          await _readLetterPackName("currentLetterPackName").then((value) {
            if (value == null) {
              print("First time, letterPackName = null");
              value = "Standard (Closed Syllable)";
            }
            letterPackName = value;
            print(letterPackName);
          });
          if (letterPackName == "discardPack") {
            print("Last pack was a discard Pack, need to load discardPack");
            //read the discard pack from shared preferences
            //List<String> tempStringList = [];
            await _read("discardPackKey").then((value) {
              discardPack = LetterPack.decodeLetterPack(value);
              letterPackMap["discardPack"] = discardPack;
            });
          }
          //isHomePressed = true;
          Navigator.push(
            context,
            FadeRoute(page: BoardScreen()),
          );
        },
      ),
    );
  }

  /**
   * Returns a button that leads the user to the My Decks Screen. 
   */
  Widget myDecksButton() {
    return Container(
        margin: EdgeInsets.only(top: 20, left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(SFSymbols.square_grid_2x2_fill),
              color: Colors.white,
              iconSize: (isLargeScreen == true)
                  ? SizeConfig.screenHeight * 0.20
                  : SizeConfig.screenHeight * 0.35, //125,
              onPressed: () {
                Navigator.push(context, SlideLeftRoute(page: MyDecksScreen()));
              },
            ),
            Text(
              "My Decks",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: (isLargeScreen == true)
                      ? SizeConfig.safeBlockVertical * 3
                      : SizeConfig.safeBlockVertical * 4,
                  color: colorsList[colorChipIndex]),
            )
          ],
        ));
  }
  /**
   * Returns a button that leads the user to the Mission Statement Screen. 
   */
  Widget missionStatementButton() {
    return Container(
        margin: EdgeInsets.only(right: 5),
        height: SizeConfig.screenWidth * (0.05),
        width: SizeConfig.screenWidth * (0.05),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            image: DecorationImage(
              fit: BoxFit.scaleDown,
              image: currentBrainLogoImage,
            ),
          ),
          child: TextButton(
            child: Text(""),
            onPressed: () {
              Navigator.push(
                  context, SlideUpRoute(page: MissionStatementScreen()));
            },
          ),
        ));
  }
  /**
   * Returns a button that leads users to the Settings Screen. 
   */
  Widget settingsButton() {
    return Container(
      height: SizeConfig.screenWidth * (0.05),
      width: SizeConfig.screenWidth * (0.05),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      /*child: IconButton(
        icon: Icon(SFSymbols.gear_alt,
          color: colorsList[colorChipIndex],
        ),*/
      child: TextButton(
        //padding: EdgeInsets.only(left: 0, right: 0),
        child: Icon(SFSymbols.gear_alt,
            color: colorsList[colorChipIndex], //Color(0xFF00a8df),
            size: SizeConfig.safeBlockHorizontal * 3),
        onPressed: () {
          Navigator.push(context, SlideUpRoute(page: SettingsScreen()));
        },
      ),
    );
  }

  /**
   * Returns a button that opens the user's camera with the user's permission. 
   */
  Widget qrCamera() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      height: SizeConfig.screenWidth * (0.05),
      width: SizeConfig.screenWidth * (0.05),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.only(left: 1, right: 0),
        ),
        child: Icon(SFSymbols.qrcode_viewfinder,
            color: colorsList[colorChipIndex], //Color(0xFF00a8df),
            size: SizeConfig.safeBlockHorizontal * 4),

        //iconSize: SizeConfig.safeBlockHorizontal * 4,
        onPressed: () {
          checkCameraPermissions();
          //_scan();
        },
      ),
    );
  }
}