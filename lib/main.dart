import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:collection/collection.dart';
import 'package:msix/msix.dart';
import 'dart:io' show Platform;
import 'screen_transitions.dart';
import 'letter_set.dart';
import 'letter_pack.dart';
import 'config/global_variables.dart';


///----main function to run app----///
void main(){
    WidgetsFlutterBinding.ensureInitialized(); 
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]).then((_){
    runApp(MyApp());
  });
}
class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
	static double safeBlockVertical;

  void init(BuildContext context) {
  _mediaQueryData = MediaQuery.of(context);
  screenWidth = _mediaQueryData.size.width;
  screenHeight = _mediaQueryData.size.height;
  blockSizeHorizontal = screenWidth / 100;
  blockSizeVertical = screenHeight / 100;

  _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
	_safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
  safeBlockHorizontal = (screenWidth -_safeAreaHorizontal) / 100;
	safeBlockVertical = (screenHeight -_safeAreaVertical) / 100;
 }
 static double getSafeAreaVertical() {
    return _safeAreaVertical;
  }
}
/*class ColorTheme{
  Color textColor;
  Color selectionColor;
  ColorTheme(Color color){
    textColor = color;
    selectionColor = color.withOpacity(0.3);
  }
}*/

_reset() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear(); 
    // allPacks.clear();  
    print("CLEARED ALL");
}

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String qrString = "";
  String beginningName = "";
  String middleName = "";
  String endName = "";
  String lpName = "";
  String beginningSubstring = "";
  String endSubstring = "";
  String letterPackSubstring = "";
  String middleSubstring = "";

  ///----Reading and Writing to Preferences----///
  
  Future<List> _read(String keyNumberString) async {
    final prefs = await SharedPreferences.getInstance();
    final key = keyNumberString;
    final value = prefs.getStringList(key) ?? [];
    //print('read: $value');
    return value;
  }

  Future<List> _readDiscardPack(String discardKey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = discardKey;
    final value = prefs.getStringList(key);
    //print(value);
    return value;
  }

  Future <int>_readInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    int intValue = prefs.getInt(key);
    return intValue;
  }

  Future <int>_readMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    int intValue = prefs.getInt("currentMode");
    return intValue;
  }
  Future <int>_readColorIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    int intValue = prefs.getInt("colorIndexKey");
    return intValue;
  }

   void readAll() async {
        await _readInt("numberOfKeys").then((value) {
              numberOfLetterPacks = value;
        });
        print(numberOfLetterPacks);
        if (numberOfLetterPacks == null){
          setState(() { 
            allPacks.clear();
            allPacks.add(defaultPacks[0]);
            allPacks.add(defaultPacks[1]);
            allPacks.add(defaultPacks[2]);
            numberOfLetterPacks = 3;
          });        
          //print("First time. Default packs will be set");
        }
        else{
          numberOfLetterPacks = numberOfLetterPacks;
          allPacks.clear();
          
          for(int i = 0; i<numberOfLetterPacks; i++){
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
        await _readMode().then((value){
          if(value == null){
            currentMode = auto;
          }
          else{
            currentMode = value;
          }
        });
        //print(isDarkModeOn);

        await _readColorIndex().then((value){
          print("value = $value");
          if(value == null){
            value = 0;
            colorChipIndex = value;
            currentColor = blueC;
            currentBackgroundImage = blueBackgroundImage;
          }
          else{
            colorChipIndex = value;
            currentColor = themeColorsList[value];
            currentBackgroundImage = backgroundImagesList[value];
            currentBrainLogoImage = brainLogoImagesList[value];
          }
        });
      }
  Future <String>_readLetterPackName(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString(key);
    return stringValue;
  }

  Future <void> readAtLogoButton() async{
    await _readLetterPackName("currentLetterPackName").then((value) {
      if (value == null){
        print("First time, letterPackName = null");
        value = "Standard (Closed Syllable)";
      }
      letterPackName = value;
      print(letterPackName);
    });
    if (letterPackName == "discardPack"){
        print("Last pack was a discard Pack, need to load discardPack");
        await _readDiscardPack("discardPackKey").then((value) {
            discardPack = LetterPack.decodeLetterPack(value);
            //adding pack to letterPackMap
            letterPackMap["discardPack"] = discardPack;
      
              
        });
      }
     
  }

///---QR Functions----///
void getBeginningSubstring(){
  print(qrString.indexOf("},"));
  beginningSubstring = qrString.substring(1, qrString.indexOf("},"));
  print("beginning substring: " +  beginningSubstring);
  qrString = qrString.substring(qrString.indexOf("},") + 2, qrString.length-1);
  print("qr string: " + qrString);
}

void getEndSubstring(){
  //print(qrString.indexOf("\"end\""));
  endSubstring = qrString.substring(0, qrString.indexOf("},"));
  print("end substring: " + endSubstring);
  qrString = qrString.substring(qrString.indexOf("},") + 2, qrString.length);

}

void getLetterPackSubstring(){
  letterPackSubstring = qrString.substring(qrString.indexOf("\"name\""), qrString.indexOf("\"middle\""));
  
  qrString = qrString.substring(qrString.indexOf("\"middle\""), qrString.length);

}

void getMiddleSubstring(){
  middleSubstring = qrString.substring(0, qrString.indexOf("}"));
}

void divideSubstring(){
  print("original qrString: " + qrString);
  print("did i get ehre");
  getBeginningSubstring();
  print(qrString);
  print("im guessing it will breka here");
  getEndSubstring();
  print("end worked");
  getLetterPackSubstring();
  print("letterpack worked");
  getMiddleSubstring();
}
LetterSet stringToLetterSetConverter(String setSubstring){
  LetterSet tempLS;
  String lsName = "";
  int positionInt = 0;
  
  setSubstring = setSubstring.replaceAll("\"","");
  print(setSubstring);
  //there are 5 characters in "name:"
  lsName = setSubstring.substring(setSubstring.indexOf("name:") + 5, setSubstring.indexOf(","));
  positionInt = int.parse(setSubstring.substring(setSubstring.indexOf("position:") + 9, setSubstring.indexOf(",letters")));
  
  List<String> lettersList = setSubstring.substring(setSubstring.indexOf("[") + 1,setSubstring.indexOf("]")).split(',').toList();
  tempLS = LetterSet(lsName, positionInt, lettersList);
  return tempLS;
}

LetterPack qrToLetterPack(){
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
  letterPackSubstring = letterPackSubstring.replaceAll("\"","");
  lpName = letterPackSubstring.substring(letterPackSubstring.indexOf("name:") + 5, letterPackSubstring.indexOf(","));
  
  tempLP = LetterPack(lpName, begLS, midLS, endLS);
  return tempLP;
}
/*List<String> stringToListConverter(String longString){
  List<String> stringList = [];
  int lengthOfElement = 0;
  //goes through the string and 
  //pol,jkhb,apo,bop,
  for(int i=0; i<longString.length; i++){
    if(longString[i] == ","){
      stringList.add(longString.substring(i-lengthOfElement, i));
      lengthOfElement = 0;
    }
    else{
      lengthOfElement++;
    } 
  }
  return stringList;
}*/
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
      _SaveScreenState._saveAll();
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
    } */catch (e){
      print("$e");
      String os = Platform.operatingSystem;
      print(os);
      if (os == "windows") {
        print('is a Windows');
        setState(() {
          showDialog(context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("QR Scanning Not Supported", textAlign: TextAlign.center),
                content: Container(
                width: SizeConfig.screenWidth * 0.3,
                height: SizeConfig.screenWidth * 0.3,
                  child: Center(
                    child: Text("Unfortunately, Windows devices do not support the ability to scan Blending Board QR codes.", textAlign: TextAlign.center),
                  )
                ),
              );
            },
            barrierDismissible: true,
          );
        });
      } 
      else {
        setState(() {
          showDialog(context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Not a Blending Board Deck", textAlign: TextAlign.center),
                content: Container(
                width: SizeConfig.screenWidth * 0.3,
                height: SizeConfig.screenWidth * 0.3,
                  child: Center(
                    child: Text("This code contains the data: $qrString, and is not a Blending Board Deck.", textAlign: TextAlign.center),
                  )
                ),
              );
            },
            barrierDismissible: true,
          );
        });
      }
    }
      
      
}
checkCameraPermissions()async {
  var cameraStatus = await Permission.camera.status;
  print(cameraStatus);
  //cameraStatus.isDenied;
  //if camera is not available -> dialog
  //if(cameraStatus.is)
  if (cameraStatus.isGranted){
    _scan(); 
  }
  else{
    //print("igot here");
    //haven't asked for permission yet -> ask for permissions
    setState(() {
      showDialog(context: context, 
      builder: (BuildContext context) {
       return AlertDialog(
        title: Text("Blending Board Would Like to Access the Camera", textAlign: TextAlign.center),
        content: Container(
         width: SizeConfig.screenWidth * 0.15,
        height: SizeConfig.screenWidth * 0.15,
          child: Center(
            child: Text("The camera is only used for scanning QR codes of decks", textAlign: TextAlign.center),
          )
           ),
          actions: <Widget>[
            TextButton(
              child: Text("Don't Allow"),
              //set status to denied
              
              onPressed: (){
                //Permission.camera.
                //cameraStatus.isDenied;
                Navigator.of(context).pop();
              }
            ),
            TextButton(
              child: Text("Allow"),
              
              onPressed: ()async {
                await Permission.camera.request();
                Navigator.of(context).pop();
                _scan();
              }
            ),
          ],
       );

      },
       barrierDismissible: false,
       
    
        );
      });
  }
  

       
}

  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
    ]);
    if (firstBuild == true){
      _reset();
      readAll();
      print(colorChipIndex);
      //var brightness = SchedulerBinding.instance.window.platformBrightness;
      //print(isDarkModeOn);
      firstBuild = false;
      //currentMode = 2;
      currentColor = themeColorsList[colorChipIndex];
      currentBackgroundImage = backgroundImagesList[colorChipIndex];
      currentBrainLogoImage = brainLogoImagesList[colorChipIndex];
      //colorChipIndex = 0;
    }
    
    print(colorChipIndex);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (MediaQuery.of(context).size.height > 600) {
      isLargeScreen = true;
    } 
    else {
      isLargeScreen = false;
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    if (currentMode == auto){
      isDarkModeOn = brightness == Brightness.dark;
    }
    else if (currentMode == light){
      isDarkModeOn = false;
    }
    else{
      isDarkModeOn = true;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'SF-Pro-Rounded',
        ),
        debugShowCheckedModeBanner: false,
        home: Stack(children: <Widget>[ 
        
          Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: currentBackgroundImage, 
                fit: BoxFit.cover
              )
            ),
        ),
        Container(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkModeOn ? Colors.black.withOpacity(0.65): Colors.black.withOpacity(0.4),
                  ),
                )
              )
            ),
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
      )
      )
        ],
      )
      )
    );
  }
  ///----Build methods for widgets in homescreen----///
  Widget mainButtonRow(){
    return Container(
    child: Row(
      //crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createDeckButton(),
          logoButton(),
          myDecksButton()
        ],
    )
   );
  }
  Widget miscButtonRow(){
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: SizeConfig._safeAreaVertical),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          missionStatementButton(),
          settingsButton(),
          qrCamera(),
        ],
    )
   );
  }
  Widget createDeckButton() {
    return Container( 
      margin: EdgeInsets.only(top: 20, right: 10,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(SFSymbols.plus_square_fill),
            color: Colors.white,
            iconSize: (isLargeScreen == true) ? SizeConfig.screenHeight * 0.20 : SizeConfig.screenHeight * 0.35,//125,
            onPressed: (){
              Navigator.push(
                context,
                SlideRightRoute(page: CreateDecksScreen()),
              );
            }  
          ),
          Text(
            "Create Deck",
            style: TextStyle(
              color: colorsList[colorChipIndex],
              fontFamily: 'SF-Pro-Rounded',
              fontWeight: FontWeight.w600,
              fontSize: (isLargeScreen == true) ? SizeConfig.safeBlockVertical * 3 : SizeConfig.safeBlockVertical * 4,
            ),
          )
        ],
      )
    );
  }
 
  Widget logoButton() {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 5, left: 5, bottom: 20),
      
      child: GestureDetector(
        child: Image(
          image: AssetImage('assets/blendingBoardLogo.png'),
          height: (isLargeScreen == true) ? SizeConfig.screenHeight * 0.50 : SizeConfig.screenHeight * 0.65,
          width: (isLargeScreen == true) ? SizeConfig.screenHeight * 0.50 : SizeConfig.screenHeight * 0.65,
        ),
        onTap: () async{
          //read
        await _readLetterPackName("currentLetterPackName").then((value) {
          if (value == null){
              print("First time, letterPackName = null");
              value = "Standard (Closed Syllable)";
            }
            letterPackName = value;
            print(letterPackName);
        });
        if (letterPackName == "discardPack"){
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
  Widget myDecksButton() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(SFSymbols.square_grid_2x2_fill),
            color: Colors.white,
            iconSize: (isLargeScreen == true) ? SizeConfig.screenHeight * 0.20 : SizeConfig.screenHeight * 0.35,//125,
            onPressed: (){
              Navigator.push(
                context,
                SlideLeftRoute(page: MyDecksScreen())
              );
            },
          ),
          Text(
            "My Decks",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: (isLargeScreen == true) ? SizeConfig.safeBlockVertical * 3 : SizeConfig.safeBlockVertical * 4,
              color: colorsList[colorChipIndex]
            ),
          )
        ],
      )
    );
  }
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
            context,
            SlideUpRoute(page: MissionStatementScreen())
          );
        },
      ),
    )
    );
  }
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
          color: colorsList[colorChipIndex],//Color(0xFF00a8df),
          size: SizeConfig.safeBlockHorizontal * 3
          ),
        onPressed: () {
          Navigator.push(
            context,
            SlideUpRoute(page: SettingsScreen())
          );
        },
      ),
    );
  }
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
          color: colorsList[colorChipIndex],//Color(0xFF00a8df),
          size: SizeConfig.safeBlockHorizontal * 4
          ),
        
        //iconSize: SizeConfig.safeBlockHorizontal * 4,
        onPressed: () {
          checkCameraPermissions();
          //_scan(); 
        },
      ),
        
      
    );
  }
}
///----Settings Screen----///

class SettingsScreen extends StatefulWidget{
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
  int modesPickerValue = 0;
  Map <int, Widget> modesMap = <int, Widget>{
    light: Text("Light"),
    auto: Text("Auto"),
    dark: Text("Dark")
  };
  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
    ]);
    if(isDarkModeOn){
      modesPickerValue = dark;
    }
    else{
      modesPickerValue = light;
    }
  }
  Widget build(BuildContext context) {
    //var brightness = MediaQuery.of(context).platformBrightness;
    //if auto is selected
    //isDarkModeOn = brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        //alignment: Alignment.center,
        children: <Widget>[
          Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: currentBackgroundImage,
                fit: BoxFit.cover
            )
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                color: isDarkModeOn ? Colors.black.withOpacity(0.65): Colors.black.withOpacity(0.4),
                ),
              )
            )
        ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: 20,
                  child: settingsColumn(),
          ),
              ]
            )
            ),
        
          Positioned(
            bottom: 20,
            left: 20,
            child: IconButton(
              icon: Icon(SFSymbols.house_fill),
              iconSize: SizeConfig.screenHeight * 0.05,
              color: colorsList[colorChipIndex], //Color(0xFF0690d4),
                onPressed: () async {  
                  //print(currentBrainLogoImage);
                  //save mode to preferences
                  print(isDarkModeOn);
                  await _saveMode(currentMode);

                  //save color to index (use to get background image and color)
                  await _saveColorIndex(colorChipIndex);

                  Navigator.push(
                    context,
                    FadeRoute(page: MyHomePage())
                  );
                    
                },
            )
          ),
        ]
      )
    );
  }
  static _saveMode(int mode) async {
        final prefs = await SharedPreferences.getInstance();
        final key = "currentMode";
        final value = mode;
        prefs.setInt(key, value);
        //print('saved $value');
  }
  static _saveColorIndex(int numValue) async {
        final prefs = await SharedPreferences.getInstance();
        final key = "colorIndexKey";
        final value = numValue;
        prefs.setInt(key, value);
        //print('saved $value');
  }
  Widget modePicker(){
    return CupertinoSlidingSegmentedControl(
      groupValue: currentMode,
      children: modesMap, 
      thumbColor: isDarkModeOn ? Colors.grey.withOpacity(0.3): Colors.white,
      onValueChanged: (i)  {
        setState(()  {
          currentMode = i;
          if(i == light){
            //light mode is selected
            isDarkModeOn = false;
            modesMap.update(light, (var val) => val = Text("Light", style: TextStyle(color: Colors.black)));
            modesMap.update(auto, (var val) => val = Text("Auto", style: TextStyle(color: Colors.black)));
            modesMap.update(dark, (var val) => val = Text("Dark", style: TextStyle(color: Colors.black)));
          }
          else if (i == auto){
            //auto mode is selected
            var brightness = SchedulerBinding.instance.window.platformBrightness;
            isDarkModeOn = brightness == Brightness.dark;
            if(isDarkModeOn){
              modesMap.update(light, (var val) => val = Text("Light", style: TextStyle(color: Colors.white)));
              modesMap.update(auto, (var val) => val = Text("Auto", style: TextStyle(color: Colors.white)));
              modesMap.update(dark, (var val) => val = Text("Dark", style: TextStyle(color: Colors.white)));
            }
            else{
              modesMap.update(light, (var val) => val = Text("Light", style: TextStyle(color: Colors.black)));
              modesMap.update(auto, (var val) => val = Text("Auto", style: TextStyle(color: Colors.black)));
              modesMap.update(dark, (var val) => val = Text("Dark", style: TextStyle(color: Colors.black)));
            }
            
          }
          else if(i == dark){
            //dark mode is selected
            isDarkModeOn = true;
            modesMap.update(light, (var val) => val = Text("Light", style: TextStyle(color: Colors.white)));
            modesMap.update(auto, (var val) => val = Text("Auto", style: TextStyle(color: Colors.white)));
            modesMap.update(dark, (var val) => val = Text("Dark", style: TextStyle(color: Colors.white)));
          }
          
        });
      }
    );  
  }
  Widget settingsColumn(){
    return Container(
      width: SizeConfig.screenWidth * 0.6,
      height: SizeConfig.screenHeight,
      //margin: EdgeInsets.only(top: SizeConfig._safeAreaVertical + 20),
      child: Column(
        children: [
          Container( 
            margin: EdgeInsets.only(top: 10, bottom: 50),
            child: Text("Settings",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorsList[colorChipIndex],
                fontSize: (SizeConfig.safeBlockHorizontal * 3),
              )
            ),
          ),
          Container(
            color: Colors.grey.withOpacity(0.5),
            height: SizeConfig.screenHeight * 0.1,
            child: modeRow(),
          ),
          Container(
            height: 100,         
            child: colorChipsRow(),
          ),
          

        ],
      )
   );
  }
  Widget modeRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 20),
          child: Text("Dark Mode",
            style: TextStyle (
              color: Colors.white, 
              fontWeight: FontWeight.w600, 
              fontSize: SizeConfig.safeBlockHorizontal * 2
            )
          ),
        ),
          
        Container(
          width: SizeConfig.screenWidth * 0.4,
          child: modePicker(),
        )
        
      ]
    );
  }
  Widget colorChipsRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 20),
          child: Text("Theme Color",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600, 
              fontSize: SizeConfig.safeBlockHorizontal * 2
            )
          ),
        ),
        
        Container(
            width: SizeConfig.screenWidth * 0.4,
            child: colorChips(),
          )
        
      ],
    );
  }
  Widget colorChips(){
    return ListView.builder(
      itemCount: themeColorsList.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        //if this is the last element, make it a star
        if(index == themeColorsList.length-1){
          return Container(
          child: ChoiceChip(
            label:  Icon(SFSymbols.star_circle_fill, color: themeColorsList[index], size: SizeConfig.safeBlockHorizontal * 4),
            
            
            selected: colorChipIndex == index,
            onSelected: (selected) {
              setState(() {
                colorChipIndex = index;
                currentColor = themeColorsList[index];
                currentBackgroundImage = backgroundImagesList[index];
                currentBrainLogoImage = brainLogoImagesList[index];
                
              });
        },
          )
        );
        }
        else{
          return Container(
          child: ChoiceChip(
              label: Icon(SFSymbols.circle_fill, color: themeColorsList[index], size: SizeConfig.safeBlockHorizontal * 4),
              /*CircleAvatar(
                maxRadius: SizeConfig.safeBlockHorizontal ,
              backgroundColor: themeColorsList[index],
            ),*/
            selected: colorChipIndex == index,
            onSelected: (selected) {
              setState(() {
                colorChipIndex = index;
                currentColor = themeColorsList[index];
                currentBackgroundImage = backgroundImagesList[index];
                currentBrainLogoImage = brainLogoImagesList[index];
              });
        },
          )
        );
        }
        
      }
    );
  }
}
 ///----Mission Statement Screen----///
 
class MissionStatementScreen extends StatefulWidget {
  @override
  _MissionStatementScreenState createState() => _MissionStatementScreenState();
}
class _MissionStatementScreenState extends State<MissionStatementScreen>{
  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
    ]);
  }
  
  final Uri _url = Uri.parse('http://dyslexicmindset.weebly.com/');
  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }


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
                fit: BoxFit.cover)
              ),
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
            top: SizeConfig._safeAreaVertical + 10,
            left: 20,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.cancel),
              iconSize: SizeConfig.screenHeight * 0.05,
              color: Colors.white
            ),
          )
        ],
      )
    )
    );
  }
  ///----Build methods for Mission Statement Screen----///
  
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
  Widget missionStatementText() {
    return Container(
      margin: EdgeInsets.all(SizeConfig._safeAreaVertical + 20),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
     
        Text("Mission:",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: SizeConfig.safeBlockHorizontal * 2.5),
          ),
        
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: SizeConfig.screenHeight/2,
            maxHeight: SizeConfig.screenWidth,
          ),
          child: Text("\nThis app was created to ensure access to FREE dyslexia resources as part of Nadine Gilkison's Google Innovator Project.\nSpecial thanks to Brayden Gogis for creating this app to help millions of teachers and students on a global scale.\nTap the brain for more FREE resources!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: SizeConfig.safeBlockHorizontal * 2),
          )
        )
      ],
      )
    );
  }
}
 ///----Create Decks Screen----///
class CreateDecksScreen extends StatefulWidget {
  @override
  _CreateDecksScreenState createState() => _CreateDecksScreenState();
}
class _CreateDecksScreenState extends State<CreateDecksScreen>{
  int _defaultBeginningChoiceIndex = 0;
  int _defaultMiddleChoiceIndex = 1;
  int _defaultEndChoiceIndex = 0;
  List <ChoiceChip> choiceChipList = [];
  static List <LetterSet> beginningSetsList = [];
  static List <LetterSet> middleSetsList = [];
  static List <LetterSet> endSetsList = [];
  static LetterSet tempBeginningSet;
  static LetterSet tempMiddleSet;
  static LetterSet tempEndSet;

  void sortChips(){
    beginningSetsList.clear();
    middleSetsList.clear();
    endSetsList.clear();
    letterSetsFromSelectedColumn.clear();
    //go through all the sets, take the ones that are beginning, and put them into a list
    for(int i = 0; i<allSets.length; i++){
      //using bit masking
       if(allSets[i].positionBinary & 1 > 0){ 
          beginningSetsList.add(allSets[i]);
       } 
       if (allSets[i].positionBinary & 2 > 0){
          middleSetsList.add(allSets[i]);
       }
       if (allSets[i].positionBinary & 4 > 0){
         endSetsList.add(allSets[i]);
       }
    }
  }
  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
    ]);
    
    sortChips();
   }
   
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
      theme: ThemeData(
        fontFamily: 'SF-Pro-Rounded',
      ),
      debugShowCheckedModeBanner: false,
      home: Stack (
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: currentBackgroundImage,
                fit: BoxFit.cover
            )
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                color: isDarkModeOn ? Colors.black.withOpacity(0.65): Colors.black.withOpacity(0.4),
                ),
              )
            )
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            
            children: <Widget>[
             choiceChipRow(),
             
              Positioned(
                bottom: 20,
                left: 20,
                child: IconButton(
                  icon: Icon(SFSymbols.house_fill),
                  iconSize: SizeConfig.screenHeight * 0.05,
                  color: colorsList[colorChipIndex], //Color(0xFF0690d4),
                  onPressed: () {
                  setState(() {
                      sortChips();
                      
                      
                    });
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                    
                  },
                )
              )
            ],
          )
        )   
      ],
      )
      )
    );
  }
  bool isLongName (String name){
    bool isLongName;
    if(name.length > 18){
      isLongName = true;
    }
    else{
      isLongName = false;
    }
    return isLongName;
  }
  ///----Build methods for widgets in Create Decks Screen----///
  Widget beginningChoiceChips() {
    return ListView.builder(
      itemCount: beginningSetsList.length,
      //itemExtent: 100,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          //height: 50,
          //width: SizeConfig.screenWidth * 0.25,
          margin: EdgeInsets.only(bottom: 10,),
         // padding: EdgeInsets.only(bottom: 10,),
            child: InputChip(
        selected: _defaultBeginningChoiceIndex == index,
        label: Container(
          width: 200,
          margin: EdgeInsets.all(10),
          child:  
            Text(beginningSetsList[index].name,
                style: TextStyle(fontSize: isLongName(beginningSetsList[index].name) ? SizeConfig.safeBlockHorizontal * 1.6 : SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center, overflow: TextOverflow.visible,
            ),
        ),
        showCheckmark: false,
        deleteButtonTooltipMessage: "Edit",
        onDeleted: () {
          setState(() {
            _defaultBeginningChoiceIndex = index;
          });
          for(int i = 0; i < beginningSetsList.length; i++){
            letterSetsFromSelectedColumn.add(beginningSetsList[i]);
          }
          selLS = beginningSetsList[index];
            Navigator.push(
              context,
              //pass letterset index
              MaterialPageRoute(builder: (context) => CustomizeLettersScreen()),
            ); 
        },
        deleteIcon: Icon(SFSymbols.pencil,
        size: SizeConfig.safeBlockHorizontal * 2.5,
        color: currentColor),
        onPressed: () {
          setState(() {
            _defaultBeginningChoiceIndex = index;
           // print("defaultindex: $defaultIndex");
           // print("listbuilder: $listBuilderIndex");
          });
        },
      
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))),
            selectedColor: currentColor.withOpacity(0.3),//Color(0xFF3478F6).withOpacity(0.3),
            backgroundColor: isDarkModeOn ? Colors.black: Colors.white,
            labelStyle: TextStyle(color: currentColor),
            )
        );
          
        },
      
    );
    
  }
  Widget middleChoiceChips() {
    return ListView.builder(
      itemCount: middleSetsList.length,
      //itemExtent: 50,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: InputChip(
        selected: _defaultMiddleChoiceIndex == index,
        label: Container(
          width: 200,
          margin: EdgeInsets.all(10),
          child:  
            Text(middleSetsList[index].name,
                style: TextStyle(fontSize: isLongName(middleSetsList[index].name) ? SizeConfig.safeBlockHorizontal * 1.6 : SizeConfig.safeBlockHorizontal * 2, 
                fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
        ),
        showCheckmark: false,
        deleteButtonTooltipMessage: "Edit",
        onDeleted: () {
          setState(() {
            _defaultMiddleChoiceIndex = index;
          });

          selLS = middleSetsList[index];
          for(int i = 0; i < middleSetsList.length; i++){
            letterSetsFromSelectedColumn.add(middleSetsList[i]);
          }   
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomizeLettersScreen()),
          );    
        },
          deleteIcon: Icon(SFSymbols.pencil,
          color: currentColor,
          size: SizeConfig.safeBlockHorizontal * 2.5,
        ),
        onPressed: () {
          setState(() {
            _defaultMiddleChoiceIndex = index;
          });
        },
      
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))),
            selectedColor: currentColor.withOpacity(0.3),
            backgroundColor: isDarkModeOn ? Colors.black: Colors.white,
            labelStyle: TextStyle(color: currentColor),
            )
        );
        
          
        },
      
    );
  }
  Widget endChoiceChips() {
      return ListView.builder(
        itemCount: endSetsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(bottom: 10,),
            child: InputChip(
        selected: _defaultEndChoiceIndex == index,
        label: Container(
          width: 200,
          margin: EdgeInsets.all(10),
          child:  
            Text(endSetsList[index].name,
                style: TextStyle(fontSize: isLongName(endSetsList[index].name) ? SizeConfig.safeBlockHorizontal * 1.6 : SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center, overflow: TextOverflow.visible,
            ),
        ),
        showCheckmark: false,
        deleteButtonTooltipMessage: "Edit",
        onDeleted: () {
          setState(() {
            _defaultEndChoiceIndex = index;
          });
          for(int i = 0; i < endSetsList.length; i++){
            letterSetsFromSelectedColumn.add(endSetsList[i]);
          }
          selLS = endSetsList[index];
            Navigator.push(
              context,
              //pass letterset index
              MaterialPageRoute(builder: (context) => CustomizeLettersScreen()),
            );  
        },
        deleteIcon: Icon(SFSymbols.pencil,
        size: SizeConfig.safeBlockHorizontal * 2.5,
        color: currentColor),
        onPressed: () {
          setState(() {
            _defaultEndChoiceIndex = index;
          });
        },
      
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))),
            selectedColor: currentColor.withOpacity(0.3),//Color(0xFF3478F6).withOpacity(0.3),
            backgroundColor: isDarkModeOn ? Colors.black: Colors.white,
            labelStyle: TextStyle(color: currentColor),
            )
        );
          
        },
      
    );
  }
  Widget checkmarkButton() {
    return Container(
      //margin: EdgeInsets.only(right: SizeConfig._safeAreaVertical + 20, left: SizeConfig._safeAreaVertical + 20),
      child: IconButton(
          icon: Icon(SFSymbols.checkmark_circle_fill),
          color: colorsList[colorChipIndex], //Color(0xFF00cbfb),
          iconSize: SizeConfig.screenHeight * 0.08,
          onPressed: () {
            setState(() {
              //sortChips();
              
              selectedBeginningSet = beginningSetsList[_defaultBeginningChoiceIndex];
              selectedMiddleSet = middleSetsList[_defaultMiddleChoiceIndex];
              selectedEndSet = endSetsList[_defaultEndChoiceIndex];
  
       
             
              print(selectedMiddleSet.lettersToRemove);
              tempBeginningSet = LetterSet(selectedBeginningSet.name, selectedBeginningSet.positionBinary, selectedBeginningSet.generateCustomLetters());
              tempMiddleSet = LetterSet(selectedMiddleSet.name, selectedMiddleSet.positionBinary, selectedMiddleSet.generateCustomLetters());
              tempEndSet = LetterSet(selectedEndSet.name, selectedEndSet.positionBinary, selectedEndSet.generateCustomLetters());
              //clear lettersToRemove and lettersToAdd

              //HAVE TO DO TO ALL, NOT JUST SELECTED
              for (LetterSet b in beginningSetsList){
                b.lettersToAdd.clear();
                b.lettersToRemove.clear();
              }
              for (LetterSet m in middleSetsList){
                m.lettersToAdd.clear();
                m.lettersToRemove.clear();
              }
              for (LetterSet e in endSetsList){
                e.lettersToAdd.clear();
                e.lettersToRemove.clear();
              }
          
              Navigator.push(
                context,
                ScaleRoute(page: SaveScreen()),
              );
            });
          },
        ),
    );
  }
  Widget emptyColumn(){
    return Container(
      width: SizeConfig.screenWidth * 0.1,
      height: SizeConfig.screenHeight,
      margin: EdgeInsets.only(top: SizeConfig._safeAreaVertical + 20, right: 5,),
      child: Column(
        children: [],
      )
    );
  }
  Widget column1(){
    return Container(
      width: SizeConfig.screenWidth * 0.25,
      height: SizeConfig.screenHeight,
      margin: EdgeInsets.only(top: SizeConfig._safeAreaVertical + 20, right: 5,),
      child: Column(
        children: [
          Container( 
            margin: EdgeInsets.only(bottom: 10),
            child: Text("Column 1",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorsList[colorChipIndex],
                fontSize: SizeConfig.safeBlockHorizontal * 3,
              )
            ), 
          ),
          Flexible(
            child: beginningChoiceChips(),
          )     
        ],
      )
    );
  }
  Widget column2(){
    return Container(
      width: SizeConfig.screenWidth * 0.25,
      height: SizeConfig.screenHeight,
      margin: EdgeInsets.only(top: SizeConfig._safeAreaVertical + 20, right: 5, left: 5,),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text("Column 2",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorsList[colorChipIndex],
                fontSize: (SizeConfig.safeBlockHorizontal * 3)
              )
            ),
          ),
          Flexible(
            child: middleChoiceChips(),
          )  
        ],
      )
    );
  }
  Widget column3(){
    return Container(
      width: SizeConfig.screenWidth * 0.25,
      height: SizeConfig.screenHeight,
      margin: EdgeInsets.only(top: SizeConfig._safeAreaVertical + 20, left: 5),
      child: Column(
        children: [
          Container( 
            margin: EdgeInsets.only(bottom: 10),
            child: Text("Column 3",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorsList[colorChipIndex],
                fontSize: (SizeConfig.safeBlockHorizontal * 3),
              )
            ),
          ),
          Flexible(
            child: endChoiceChips(),
          )  
        ],
      )
    );
  }
  Widget choiceChipRow(){
    return Row(
      children: [
        emptyColumn(),
        column1(),
        column2(),
        column3(),
        checkmarkButton(),
      ],
    );
  }
  
}
///----Customize Letters Screen----///

 class CustomizeLettersScreen extends StatefulWidget {
  @override
  _CustomizeLettersState createState() => _CustomizeLettersState();
}
class _CustomizeLettersState extends State<CustomizeLettersScreen> {
  final _controller = TextEditingController();
  List<Color> selectedColorsList = [Color(0xFF2250be), Color(0xffe0353a), Colors.orange, Color(0xFF315d3a), Color(0xFF553777), Color(0xFFf13850), Color(0xFF6d6e71), Color(0xFF217b82)];
  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
    ]);
    print(letterSetsFromSelectedColumn);
  }
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  bool isSelectedChecker(LetterSet lset){
    //check equality of two lists
    Function eq = const ListEquality().equals;
    bool isAdded = true;
    if(selLS.lettersToAdd.length == 0 || eq(selLS.letters, lset.letters)){
      isAdded = false;
    }
    else{
      for(int i = 0; i < lset.letters.length; i++){
        //if the pack u are making does not have the letters from the set then
        //that set is not selected
        if(!selLS.lettersToAdd.contains(lset.letters[i]) && !selLS.letters.contains(lset.letters[i])){
          print(lset.letters[i]);
          isAdded = false;
          break;
        }
      }
    }
    return isAdded;
  }

  Widget build(BuildContext context) {
    final double itemWidth = SizeConfig.screenWidth/50;
    final double itemHeight = SizeConfig.screenWidth/50;
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF1b454f),
        body: Stack(
          children: <Widget>[
            Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: currentBackgroundImage,
                fit: BoxFit.cover
            )
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                color: isDarkModeOn ? Colors.black.withOpacity(0.65): Colors.black.withOpacity(0.4),
                ),
              )
            )
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                selectedColumn(),
                Container(
                  margin: EdgeInsets.all(30),
                  width: SizeConfig.screenWidth * 0.35,
                  height: SizeConfig.screenHeight,
                  
                  child: gridView(itemWidth, itemHeight),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      letterSetsFromSelectedColumn.clear();
                    });
                  },
                  icon: Icon(SFSymbols.checkmark_circle_fill),
                  iconSize: SizeConfig.screenHeight * 0.08,
                  color: colorsList[colorChipIndex],
                ),
             
            
              ]
            ),
        )
          ]
        )
      )
      )
    );
  }
///----Build methods for widgets in Customize Letters Screen----///
  bool isLongName (String name){
    bool isLongName;
    if(name.length > 18){
      isLongName = true;
    }
    else{
      isLongName = false;
    }
    return isLongName;
  }
  Widget selectedColumn(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child:selectedColumnChips(),
          width: SizeConfig.screenWidth * 0.5,
          height: SizeConfig.screenHeight * 0.9
        )
        
      ],
    );
  }
  Widget selectedColumnChips(){
    return ListView.builder(
      itemCount: letterSetsFromSelectedColumn.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        //if this is the selected element, make return it
        if(index == letterSetsFromSelectedColumn.indexWhere((element) => element == selLS)){
          return Container(
            margin: EdgeInsets.only(bottom: 10,),
            child: InputChip(
            selected: true,
            label: Container(
              width: SizeConfig.screenHeight * 0.4,
              margin: EdgeInsets.all(10),
              child:  Text(selLS.name,
                        style: TextStyle(fontSize: isLongName(selLS.name) ? SizeConfig.safeBlockHorizontal * 1.6 : SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
            ),
            showCheckmark: false,
            deleteButtonTooltipMessage: "Add",
            onDeleted: () {

            },
            deleteIcon: Icon(SFSymbols.pencil,
              size: SizeConfig.safeBlockHorizontal * 3,
              color: currentColor,
            ),
            onPressed: () {
              setState(() {
              });
            },
      
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))),
            selectedColor: currentColor.withOpacity(0.3),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: currentColor),
            )
          );
        }
        else{
          return Container(
            margin: EdgeInsets.only(bottom: 10,),
            child: InputChip(
            label: Container(
              width: SizeConfig.screenHeight * 0.4,
              margin: EdgeInsets.all(10),
              child:  Text(letterSetsFromSelectedColumn[index].name,
                        style: TextStyle(fontSize: isLongName(letterSetsFromSelectedColumn[index].name) ? SizeConfig.safeBlockHorizontal * 1.6 : SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
            ),
            showCheckmark: false,
            deleteButtonTooltipMessage: "Add",
            onDeleted: () {

            },
            deleteIcon: Icon(SFSymbols.plus,
              size: SizeConfig.safeBlockHorizontal * 3,
              color: currentColor,
            ),
            selected: isSelectedChecker(letterSetsFromSelectedColumn[index]),
            
            onSelected: (bool selected){
              setState(() {
                  if(selected){
                    //not selected yet, you are selecting now
                    //adding the letters
                    for(int i = 0; i < letterSetsFromSelectedColumn[index].letters.length; i++){
                      //no repeat letters
                      if(!selLS.letters.contains(letterSetsFromSelectedColumn[index].letters[i])){
                        selLS.lettersToAdd.add(letterSetsFromSelectedColumn[index].letters[i]);
                      }
                    }
                  }
                  else{
                    //already selected, you are deselecting now
                    for(int i = 0; i < letterSetsFromSelectedColumn[index].letters.length; i++){
                      selLS.lettersToAdd.remove(letterSetsFromSelectedColumn[index].letters[i]);
                    } 
                  }
                });
            },
      
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))),
            selectedColor: currentColor.withOpacity(0.3),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: currentColor),
            )
          );
        }
        
      }
    );
  }
  Widget gridView(double width, double height) {
    return  GridView.count(
      // Create a grid with 3 columns. If you change the scrollDirection to
      // horizontal, this produces 3 rows.
      crossAxisCount: 3,
      childAspectRatio: (width / height),
      // Generate allPacks.length amount widgets that display their index in the List.
      children: List.generate(selLS.letters.length + 1 + selLS.lettersToAdd.length, (index) {
        
       
        //last element of gridview should be a textformfield
        if(index == selLS.letters.length + selLS.lettersToAdd.length){
          return Container(
            margin: EdgeInsets.only(top: 20, right: 5, left: SizeConfig._safeAreaVertical + 10, bottom: 5),
            decoration: BoxDecoration(),
            child:TextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),],
              style: TextStyle(color: colorsList[colorChipIndex], fontWeight: FontWeight.w600, fontSize: SizeConfig.safeBlockHorizontal * 3),
              onFieldSubmitted: (String input){
                setState(() {
                  //when text is submitted to the textformfield, the letters are added to lettersToAdd list of the selected letterset
                  selLS.lettersToAdd.add(input);
                  _controller.clear();
                });        
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "+",
                hintStyle: TextStyle(color: colorsList[colorChipIndex], fontSize: SizeConfig.safeBlockHorizontal * 3),
                contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.screenWidth * 0.02,),
                fillColor: Colors.black.withOpacity(0.3),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none
                )
              ),
              controller: _controller,
            ), 
          );
        }
        //sorting letters that were manually added, putting their filterchips after original letters 
        else if(selLS.letters.length-1<index && index < selLS.letters.length + selLS.lettersToAdd.length){
          return Container(
            margin: EdgeInsets.only(top: 5, right: 5, left: SizeConfig._safeAreaVertical + 10, bottom: 5),
            child: FilterChip(
              label: Container(
                margin: EdgeInsets.all(0),
                width: 50,
                height: 50,
                child: Center(
                //fit: BoxFit.fitWidth,
                child: AutoSizeText(selLS.lettersToAdd[index-selLS.letters.length],
                  overflow: TextOverflow.visible,
                  style: TextStyle(color: colorsList[colorChipIndex], 
                  fontSize: SizeConfig.safeBlockHorizontal * 3, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: !selLS.lettersToRemove.contains(selLS.lettersToAdd[index-selLS.letters.length]) == true ? colorsList[colorChipIndex] : Colors.transparent,
                ),
              ),
              selected: !selLS.lettersToRemove.contains(selLS.lettersToAdd[index-selLS.letters.length]),
              selectedColor: selectedColorsList[colorChipIndex],
              backgroundColor: Color(0xFF5c6464),
              showCheckmark: false,
              onSelected: (bool selected) {
                setState(() {
                  if(selected){
                    //not selected yet, you are selecting now
                    //(undoing the remove) you do not want to remove this letter from the letter set, so remove it form removeMiddleLetterList
                    selLS.lettersToRemove.remove(selLS.lettersToAdd[index-selLS.letters.length]);
                  }
                  else{
                    //already selected, you are deselecting now
                    //adding letter you want to remove into removeMiddleLetterList
                    selLS.lettersToRemove.add(selLS.lettersToAdd[index-selLS.letters.length]); 
                  }
                });
              }
            )
          );
        }
        else{
          print("current index (original): " + index.toString());
          return Container(
            margin: EdgeInsets.only(top: 5, right: 5, left: SizeConfig._safeAreaVertical + 10, bottom: 5),
            child: FilterChip(
              selected: !selLS.lettersToRemove.contains(selLS.letters[index]),
              label:  Container(
                margin: EdgeInsets.all(0),
                width: 50,
                height: 50,
                child: Center(
                  child: AutoSizeText(selLS.letters[index],
                  overflow: TextOverflow.visible,
                  //if the letter is not part of the lettersToRemove list, it should be selected
                  style: TextStyle(
                    color: colorsList[colorChipIndex],
                    //color: !mid.lettersToRemove.contains(mid.letters[index]) == true ?  Color(0xFF78cbff): Color(0xFF78c9ff), 
                  fontSize: SizeConfig.safeBlockHorizontal * 3, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,),
                )
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: !selLS.lettersToRemove.contains(selLS.letters[index]) == true ? colorsList[colorChipIndex] : Colors.transparent,
                  ),
                ),
             
              selectedColor: selectedColorsList[colorChipIndex], //Colors.orange,//Color(0xFF2250be),
              backgroundColor: Color(0xFF5c6464),
         
              showCheckmark: false,
              onSelected: (bool selected) {
                setState(() {
                  if(selected){
                    //not selected yet, you are selecting now
                    //undoing the remove
                    selLS.lettersToRemove.remove(selLS.letters[index]);
                  }
                  else{
                    //already selected, you are deselecting now
                    selLS.lettersToRemove.add(selLS.letters[index]);
                   
                  }
                });
              }
            )
           
            );
        }
        
          
      }),
    
     
    );
  }
}
///----Save Screen----///
class SaveScreen extends StatefulWidget {
  @override
  _SaveScreenState createState() => _SaveScreenState();
}
class _SaveScreenState extends State<SaveScreen> {
  final _controller = TextEditingController();

///---Saving to Preferences----///
  static _saveInt(int numValue) async {
        final prefs = await SharedPreferences.getInstance();
        final key = "numberOfKeys";
        final value = numValue;
        prefs.setInt(key, value);
        //print('saved $value');
  }
  static _saveLetterPack(List<String> stringList, String keyName) async {
        LetterPack.encodeAll();
        final prefs = await SharedPreferences.getInstance();
        final key = keyName;
        final value = stringList;
        prefs.setStringList(key, value);
        //print('saved $value');
  }
  static _saveAll() async {
        numberOfLetterPacks++;
        LetterPack.encodeAll();
        print("encode all success!");
        await _saveInt(numberOfLetterPacks);
        print("saveInt success!");
        //goes through allData (list of string lists), which saves each letter pack
        for(int i=0; i<numberOfLetterPacks; i++){
          await _saveLetterPack(allData[i], i.toString());
        }
        print('Saved All');
        print(numberOfLetterPacks);
  }
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
    ]);
  }
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
      theme: ThemeData(
        fontFamily: 'SF-Pro-Rounded',
      ),
      home: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: currentBackgroundImage, 
                fit: BoxFit.cover
              )
            ),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkModeOn ? Colors.black.withOpacity(0.65): Colors.black.withOpacity(0.4),
                  ),
                )
            )
        ),
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Column(
            children: <Widget>[
              Container( 
                margin: EdgeInsets.only(top: SizeConfig._safeAreaVertical + 20, bottom: 5),
                child: Text("Save Your Deck?",
                style: TextStyle(color: colorsList[colorChipIndex], //Color(0xFF1079c4), 
                fontWeight: FontWeight.w700, fontSize: SizeConfig.safeBlockHorizontal * 4),
                ),
              ),
              textSaveRow(),
              skipSaveButton(), 
            ],
          )
        )
      ],
      )
      )
    );
  }
  ///----Build methods for widgets in Save Screen----///
  Widget textSaveRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
      Spacer(),
      textFormField(),
      Expanded(
          child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: saveButton(),
        ),
      ),
      ],
    );
  }
  
  Widget textFormField(){
    return Container(
      width: SizeConfig.screenWidth * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
      ),
      child: Form(
        key: _formKey,
        child: TextFormField(
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          textAlign: TextAlign.center,
          controller: _controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.screenWidth * 0.02,),
            fillColor: Colors.white.withOpacity(0.3),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none
            ),
            
            hintText: 'Deck Name',
            hintStyle: TextStyle(color: Color(0xFF373737), fontWeight: FontWeight.w500, fontSize: SizeConfig.safeBlockHorizontal * 2.5),
        ),
        )
      )
    );
  }
  Widget saveButton() {
    return Container(
      margin: EdgeInsets.all(20),
      child:IconButton(
          icon: Icon(SFSymbols.checkmark_circle_fill),
          iconSize: SizeConfig.screenWidth * 0.05,
        color: colorsList[colorChipIndex],
        onPressed: (){
 
          if (_formKey.currentState.validate()) {
          setState(() {
            allPacks.add(new LetterPack(_controller.text, _CreateDecksScreenState.tempBeginningSet, _CreateDecksScreenState.tempMiddleSet, _CreateDecksScreenState.tempEndSet));
            letterPackName = _controller.text;
            //put new letterPack into letterPackMap
            letterPackMap[allPacks.last.name] = allPacks.last;
            _saveAll();
            Navigator.push(
              context,
              FadeRoute(page: BoardScreen()),
          );
          }); 
          }
        },
      ),
    );
  }
  Widget skipSaveButton() {
    return Container(
      margin: EdgeInsets.all(20),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.black,
          backgroundColor: Colors.transparent,
        ),
        child: Text("Skip, Don't Save Deck",
          style: TextStyle(decoration: TextDecoration.underline, 
          color: colorsList[colorChipIndex], //Color(0xFF0094c8), 
          fontWeight: FontWeight.w500, fontSize: SizeConfig.safeBlockHorizontal * 2),
        ),
        onPressed: ()async {
            //Load the discard pack to the blending board
            discardPack = LetterPack("discardPack", _CreateDecksScreenState.tempBeginningSet, _CreateDecksScreenState.tempMiddleSet, _CreateDecksScreenState.tempEndSet);
            letterPackName = "discardPack";
            letterPackMap["discardPack"] = discardPack;
            
            //Save the discard letter pack
            List <String> tempEncodedStringList = [];
            discardPack.dataEncode(tempEncodedStringList);
            await _saveLetterPack(tempEncodedStringList, "discardPackKey");
            print(tempEncodedStringList);
            Navigator.push(
              context,
              FadeRoute(page: BoardScreen()),
          );
        },
      ),
    );
  }
}


 ///----My Decks Screen----///
 
class MyDecksScreen extends StatefulWidget {
  @override
  _MyDecksScreenState createState() => _MyDecksScreenState();
}
class _MyDecksScreenState extends State<MyDecksScreen> {
  @override

  void initState(){
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
    final double itemHeight = itemWidth/5;
  
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
              image: currentBackgroundImage, 
                fit: BoxFit.cover
            )
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                color: isDarkModeOn ? Colors.black.withOpacity(0.65): Colors.black.withOpacity(0.4),
                ),
              )
            )
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: 20,
                  child: myDecksColumn(itemWidth, itemHeight),
                ),
            Positioned(
              bottom: 20,
              left:  20,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    //FadeSlideRightRoute(page: MyApp()),
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
                icon: Icon(SFSymbols.house_fill),
                iconSize: SizeConfig.screenHeight * 0.05,
                color: colorsList[colorChipIndex],//Color(0xFF0690d4)
              ),
            ), 
            Positioned(
              bottom: 20,
              right:  20,
              child: IconButton(
                onPressed: () {
                  showDialog(context: context, 
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Are you sure you want to clear all decks?", textAlign: TextAlign.center),
                      content: Container(
                      width: SizeConfig.screenWidth * 0.3,
                      height: SizeConfig.screenWidth * 0.3,
                        child: Center(
                          child: Text("All decks will be deleted except for the default decks.", textAlign: TextAlign.center),
                        )
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text("NO"),
                            onPressed: (){
                              Navigator.of(context, rootNavigator: true).pop(context);
                            }
                          ),
                          TextButton(
                            child: Text("YES"),
                            onPressed: (){
                              Navigator.of(context, rootNavigator: true).pop(context);
                               _reset();
                              firstBuild = true;
                              Navigator.push(
                                context,
                                FadeRoute(page: MyHomePage()),
                              );
                            }
                          ),
                        ],
                    );
                  }

                );
                  
                },
                icon: Icon(SFSymbols.trash_fill),
                iconSize: SizeConfig.screenHeight * 0.05,
                color: colorsList[colorChipIndex],//Color(0xFF0690d4)
              ),
            ),     
              ]
            )
          ) 
            
          ],
        
      )
      )
    );
  }
  ///----Build methods for My Decks Screen----///

  Widget myDecksColumn(double width, double height){
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
              )
            ),
          ),
          
          gridView(width, height),
        
          
        ],
      )
    );
  }
  Widget gridView(double width, double height) {
    return ConstrainedBox(
      constraints: new BoxConstraints(
      maxHeight: SizeConfig.screenWidth,
      maxWidth: SizeConfig.screenWidth - SizeConfig._safeAreaVertical
    ),

    child: GridView.count(
      // Create a grid with 3 columns. If you change the scrollDirection to
      // horizontal, this produces 3 rows.
      crossAxisCount: 3,
      childAspectRatio: (width / height),
      // Generate allPacks.length amount widgets that display their index in the List.
      children: List.generate(allPacks.length, (index) {
        //left deck
        if (index % 3 == 0){
          return Container(
            margin: EdgeInsets.only(top: 5, right: 5, left: SizeConfig._safeAreaVertical + 30, bottom: 5),
            child: TextButton(
              style: TextButton.styleFrom(
                primary: currentColor,
                backgroundColor: isDarkModeOn ? Colors.black: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(allPacks[index].name,
                  style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ),
                
                onPressed: (){
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
          else if ((index-2) % 3 == 0){
            return Container(
              margin: EdgeInsets.only(top: 5, right: SizeConfig._safeAreaVertical + 30, left: 5, bottom: 5),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: currentColor, //Color(0xFF0342dc),
                  backgroundColor: isDarkModeOn ? Colors.black: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),

                ),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(allPacks[index].name,
                    style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
                  ), 
                  onPressed: (){
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
                else{
                  return Container(
                    //width: width,
                    //height: height,
                    margin: EdgeInsets.only(top: 5, right: 20, left: 20, bottom: 5),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: currentColor,
                        backgroundColor: isDarkModeOn ? Colors.black: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(allPacks[index].name,
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500
                          ),
                          textAlign: TextAlign.center
                        ),
                      ), 
                      onPressed: (){
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

  
  Color checkTextColor(String letter){
    if(isDarkModeOn == true){
      return Colors.white;
    }
    else{
      if(checkVowels(letter) == true){
        return Color(0xFFb46605);
      }
      else{
        return Colors.black;
      }
    }
  }
  Color checkBackgroundColor(String letter){
    Color backgroundColor;
    if(isDarkModeOn){
      backgroundColor = (Colors.black);
    }
    else{
      backgroundColor = (Colors.white);
    }
    if(isDarkModeOn && checkVowels(letter)){
      backgroundColor =  Color(0xFF4d4003);
    }
    else if (!isDarkModeOn && checkVowels(letter)){
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
    
  
  bool checkVowels(String letter){
    if(letter.toLowerCase() == 'a'||letter.toLowerCase() == 'e'||letter.toLowerCase() == 'i'||letter.toLowerCase() == 'o'||letter.toLowerCase() == 'u'){
      return true;
    }
    else{
      return false;
    }
  }
  
  _saveLetterPackName(String stringValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "currentLetterPackName";
    final value = stringValue;
    prefs.setString(key, value);
  }
  
  String listToStringConverter(List<String> stringList){
    String stringData = "";
    //convert stringlist to a string 
    for(int i=0; i<stringList.length; i++){
      stringData += stringList[i];
      //the comma separates each element of QRStringList
      stringData += ",";
    }
    return stringData;
  }
  
  @override
  void initState(){
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
        body: Stack(
          children: [
            Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                image: DecorationImage(
                  image: currentBackgroundImage,
                fit: BoxFit.cover)
                ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: homeButton(),
            ),
            Positioned(
              top: 5 + SizeConfig._safeAreaVertical,
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
                  showDialog(context: context, 
                  builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          width: SizeConfig.screenHeight - 20,
                          height: SizeConfig.screenHeight - 20,
                          child: Center(
                            child: QrImage(
                              data: letterPackMap[letterPackName].dataEncodeiOS(),
                              version: QrVersions.auto,
                            //size: 100,
                            )
                          ),
                        )
                      );
                  }
                  );
                },
              ),
              )
            ),
            Positioned(
              top: 5 + SizeConfig._safeAreaVertical,
              left: 20,
              child: shuffleButton(),
            ),
           
            Align(
              alignment: Alignment.center,
              child: cardButtonRow(),
            )
            
          ]
        )
      )
      )
    );
  }
  /// ---- Build Methods for Widgets on Blending Board Screen ----///
  Widget homeButton(){
    return CircleAvatar(
                backgroundColor: Colors.black54,
                radius: (SizeConfig.screenHeight * 0.05),
                child: IconButton(
                icon: Icon(SFSymbols.house_fill),
                iconSize: SizeConfig.screenHeight * 0.05,
                color: colorsList[colorChipIndex], //Color(0xFF0690d4),
                onPressed: () {                  
                    Navigator.push(
                    context,
                    FadeRoute(page: MyHomePage())
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
  Widget shuffleButton(){
    return CircleAvatar(
      backgroundColor: isShufflePressed == false ? Colors.black54: colorsList[colorChipIndex],
      radius: (SizeConfig.screenHeight * 0.05),
      child: IconButton(
        icon: Icon(SFSymbols.shuffle),
        iconSize: SizeConfig.screenHeight * 0.05,
        color: isShufflePressed == false ? colorsList[colorChipIndex] : Colors.black,//isShufflePressed == false ? Color(0xFF0690d4): Color(0xFF000000),
        onPressed: () {
          isShufflePressed = !isShufflePressed;
          if(isShufflePressed == true){
            //if shuffle is pressed, randomize
            setState(() {
              counter1 = random.nextInt(letterPackMap[letterPackName].beginning.letters.length);
              beginningCardName = letterPackMap[letterPackName].beginning.letters[counter1];
              counter2 = random.nextInt(letterPackMap[letterPackName].middle.letters.length);
              middleCardName = letterPackMap[letterPackName].middle.letters[counter2];
              counter3 = random.nextInt(letterPackMap[letterPackName].end.letters.length);
              endCardName = letterPackMap[letterPackName].end.letters[counter3];
            });
          }
          else{
            //if shuffle is not pressed, set to original
            setState(() {
              counter1 = 0;
              beginningCardName = letterPackMap[letterPackName].beginning.letters[counter1];
              counter2 = 0;
              middleCardName = letterPackMap[letterPackName].middle.letters[counter2];
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
        
        child:  TextButton(
          style: TextButton.styleFrom(
            primary: checkTextColor(beginningCardName),
            backgroundColor: checkBackgroundColor(beginningCardName),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          child: AutoSizeText(beginningCardName,
          maxLines: 1,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 10, 
              fontFamily: "DidactGothic", 
              fontWeight: FontWeight.w400
              ),
          ),
          
          
            //color: checkVowels(beginningCardName) ? Color(0xFFfdf0b1) : Colors.white,
            //textColor: checkVowels(beginningCardName) ? Color(0xFFb46605) : Colors.black,
            
            onPressed: (){  
              setState(() {
                counter1++;
                if(counter1 >= letterPackMap[letterPackName].beginning.letters.length){
                  counter1 = 0;
                }
                beginningCardName = letterPackMap[letterPackName].beginning.letters[counter1];
              });
            },
          ),
        )
      
      );
  }
  Widget beginningCardBackground() {
    return Container(
      width: SizeConfig.screenWidth * 0.27,
      height: SizeConfig.screenWidth * 0.27,
      margin: EdgeInsets.only(top: 20, right: 5, left: 20, bottom: 20),
      decoration: BoxDecoration(
        color: isDarkModeOn ? Colors.black: Colors.white,
        borderRadius: BorderRadius.circular(10)
      )
    );
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
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          child: AutoSizeText(middleCardName,
            maxLines: 1,
            //minFontSize: 25.0,
            style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 10, 
            fontFamily: "DidactGothic", fontWeight: FontWeight.w400,),
          ),
          onPressed: (){
            setState(() {
              counter2++;
              if(counter2 >= letterPackMap[letterPackName].middle.letters.length){
                counter2 = 0;
              }
              middleCardName = letterPackMap[letterPackName].middle.letters[counter2];
            });
          },
        ),
      )
    );
  }
  Widget middleCardBackground() {
    return Container(
      width: SizeConfig.screenWidth * 0.27,
      height: SizeConfig.screenWidth * 0.27,
      margin: EdgeInsets.only(top: 20, right: 5, left: 5, bottom: 20),
      decoration: BoxDecoration(
        color: checkBackgroundColor(middleCardName),
        borderRadius: BorderRadius.circular(10)
      )
    );
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          child: AutoSizeText(endCardName,
          maxLines: 1,
          style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 10, fontFamily: "DidactGothic", fontWeight: FontWeight.w400),), 
          onPressed: (){
            setState(() {
              counter3++;
              if(counter3 >= letterPackMap[letterPackName].end.letters.length){
                counter3 = 0;
              }
              endCardName = letterPackMap[letterPackName].end.letters[counter3];
            });
            
            },
          )
        ),
      );
  }
  Widget endCardBackground() {
    return Container(
      width: SizeConfig.screenWidth * 0.27,
      height: SizeConfig.screenWidth * 0.27,
      margin: EdgeInsets.only(top: 20, right: 20, left: 5, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      )
    );
  }
  Widget cardButtonRow(){
    return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          beginningCardButton(),
          middleCardButton(),
          endCardButton(),
        ],
    )
   );
  }
  Widget cardBackgroundRow(){
    return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          beginningCardBackground(),
          middleCardBackground(),
          endCardBackground(),
        ],
    )
   );
  }

}