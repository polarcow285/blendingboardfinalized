import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';


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
}

///----Screen Transition Classes----///
class MyPopupRoute extends PopupRoute {
  MyPopupRoute({
    @required this.builder,
    this.dismissible = true,
    this.label,
    this.color,
    RouteSettings setting,
  }) : super(settings: setting);

  final WidgetBuilder builder;
  final bool dismissible;
  final String label;
  final Color color;
  
  static const String routeName = "/mypopup";

  @override
  Color get barrierColor => color;

  @override
  bool get barrierDismissible => dismissible;

  @override
  String get barrierLabel => label;
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity:animation,
      child: child,
    );
  }
 }
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: animation,
                child: child,
              ),
        );
}
class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;
  SlideLeftRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        );
}
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        );
}
class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  SlideUpRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        );
}
class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
                scale: Tween<double>(
                  begin: -1.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: child,
              ),
        );
}
/*class ColorTheme{
  Color textColor;
  Color selectionColor;
  ColorTheme(Color color){
    textColor = color;
    selectionColor = color.withOpacity(0.3);
  }
}*/

///----Custom Colors----///
Color blueC = const Color(0xFF0342dc);
Color redC = const Color(0xFFEB4D3D);
Color honeyC = const Color(0xFFF7CE46);
Color greenC = const Color(0xFF64C466);
Color purpleC = const Color(0xFFA358D7);
Color pinkC = const Color(0xFFEA455A);
Color slateC = const Color(0xFF8E8E93);
Color themeC = const Color(0xFF00E0B8);
Color currentColor; 

List <Color> themeColorsList = [blueC, redC, honeyC, greenC, purpleC, pinkC, slateC, themeC];
List <Color> colorsList = [Colors.blue, Colors.redAccent[100], Colors.yellow[700], Colors.green, Color(0xFFa056a5), Color(0xFFff9ee2), Color(0xFFfffffe), Color(0xFF84ffff)];
///----Custom Background Images----///
AssetImage blueBackgroundImage = AssetImage("assets/water-blue-ocean.jpg");
AssetImage redBackgroundImage = AssetImage("assets/backgroundRed.jpg");
AssetImage yellowBackgroundImage = AssetImage("assets/backgroundYellow.jpg");
AssetImage greenBackgroundImage = AssetImage("assets/backgroundGreen.jpg");
AssetImage purpleBackgroundImage = AssetImage("assets/backgroundPurple.jpg");
AssetImage pinkBackgroundImage = AssetImage("assets/backgroundPink.jpg");
AssetImage grayBackgroundImage = AssetImage("assets/backgroundGrey.jpg");
AssetImage themeBackgroundImage = AssetImage("assets/winterBackground.jpg");
AssetImage currentBackgroundImage;

List<AssetImage> backgroundImagesList = [blueBackgroundImage, redBackgroundImage, yellowBackgroundImage, greenBackgroundImage, purpleBackgroundImage, pinkBackgroundImage, grayBackgroundImage, themeBackgroundImage];

///---- Outline Dyslexia Brain Logo Images ----///
AssetImage blueBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoBlue.png");
AssetImage redBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoRed.png");
AssetImage yellowBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoYellow.png");
AssetImage greenBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoGreen.png");
AssetImage purpleBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoPurple.png");
AssetImage pinkBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoPink.png");
AssetImage grayBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoGray.png");
AssetImage themeBrainLogoImage = AssetImage("assets/outlineDyslexiaBrainLogoTheme.png");
AssetImage currentBrainLogoImage;

List brainLogoImagesList = [blueBrainLogoImage, redBrainLogoImage, yellowBrainLogoImage, greenBrainLogoImage, purpleBrainLogoImage, pinkBrainLogoImage, grayBrainLogoImage, themeBrainLogoImage];
///----Letter Set and Letter Pack Classes and Variables----///
List<String> dataStringList = [];
List <List> allData = [];
int numberOfLetterPacks;
LetterPack discardPack;
class LetterSet{
  String name;
  int positionBinary; //for 3 collumns
  //List <String> position;
  List<String> letters;
  List<String> lettersToRemove;
  List<String> lettersToAdd;
  
  LetterSet(String nameString, int positionInt, List<String> letterList){
    name = nameString;
    positionBinary = positionInt;
    /*position = positionList;
    if (positionList[0] == "sides"){
      position = ["beginning", "end"];
      positionBinary = 5; //101 in binary
    }
    if (positionList[0] == "all"){
      position = ["beginning", "middle", "end"];
      positionBinary = 7; //111
    }
    if (positionList[0] == "latterHalf"){
      position = ["middle", "end"];
      positionBinary = 3; //011
    }*/
    letters = letterList;
    lettersToRemove = [];
    lettersToAdd = [];
  }
  List<String> generateCustomLetters(){
    List<String> tempList = [];

    //copy letters from original letter set to edited one
    for(int i = 0; i<letters.length; i++){
      tempList.add(letters[i]);
    }

    //removing letters
    for(int j = 0; j<lettersToRemove.length; j++){
      tempList.remove(lettersToRemove[j]);
    }

    //adding letters
    for(int k = 0; k<lettersToAdd.length; k++){
      tempList.add(lettersToAdd[k]);
    }
    //if the user has deleted all the letters, input a blank space into the list
    //this prevents a crash when the BoardScreen tries to load
    if(tempList.length == 0){
      tempList.add(" ");
    }
    return tempList;
  }
  
  void dataEncode(List<String> stringList){
    stringList.add("#" + name);
    stringList.add("$positionBinary");
    for(int i=0; i<letters.length; i++){
      stringList.add(letters[i]);
    }
  }

  String dataEncodeiOS(){
    String encodedLetterSet = "";
    //stringList.add("{\"$position\":");
    encodedLetterSet += ("{\"name\":");
    encodedLetterSet += ("\"$name\",");
    encodedLetterSet += ("\"position\":");
    encodedLetterSet += ("$positionBinary");
    encodedLetterSet += (",");
    encodedLetterSet += ("\"letters\":");
    encodedLetterSet += ("[");
    
    for(int i=0; i<letters.length; i++){
      if(i == letters.length - 1){
        encodedLetterSet += ("\"${letters[i]}\"]}");
      }
      else{
        encodedLetterSet += ("\"${letters[i]}\",");
      }
      
    }
    return encodedLetterSet;
  }
  void letterSetInfo(){
    print (name);
    print (positionBinary);
    print (letters);
  }
  
}

class LetterPack{
  String name;
  LetterSet beginning;
  LetterSet middle;
  LetterSet end;
  
  List<LetterSet> sets;
  
  LetterPack(String nameString, LetterSet beg, LetterSet mid, LetterSet e){
    name = nameString;
    beginning = beg;
    middle = mid;
    end = e;
    
    sets = [beginning, middle, end];
    
  }
  void dataEncode(List<String> stringList){
    stringList.add(name);
    beginning.dataEncode(stringList);
    middle.dataEncode(stringList);
    end.dataEncode(stringList);
  }
  
  void letterPackInfo(){
    print (name);
    print (beginning.name);
    print (beginning.letters);
    print (middle.name);
    print (middle.letters);
    print (end.name);
    print (end.letters);
  }
  
  static void encodeAll(){
    for (int i=0; i<allPacks.length; i++){
      List <String> temp = [];
      allPacks[i].dataEncode(temp);
      //add stuff from temp into dataStringList
      allData.add(temp);
    }
  }
  String dataEncodeiOS(){
    String encodedLetterPack = "";
    encodedLetterPack += "{";
    encodedLetterPack += "\"beginning\":";
    encodedLetterPack += beginning.dataEncodeiOS();
    encodedLetterPack += ",";

    encodedLetterPack += "\"end\":";
    encodedLetterPack += end.dataEncodeiOS();
    encodedLetterPack += ",";

    encodedLetterPack += "\"name\":";
    encodedLetterPack += "\"$name\"";
    encodedLetterPack += ",";

    encodedLetterPack += "\"middle\":";
    encodedLetterPack += middle.dataEncodeiOS();
    encodedLetterPack += "}";

    return encodedLetterPack;
  }
  static int stringToPositionInt(String s){
    //because old construcotr had a list of length one that told what the position was
    //new constructor uses int
    switch (s){
      case "beginning":{
        return 1;
      }
      break;
      case "middle":{
        return 2;
      }
      break;
      case "end":{
        return 4;
      }
      break;
      case "sides":{
        return 5;
      }
      break;
      case "latterHalf":{
        return 6;
      }
      break;
      case "all":{
        return 7;
      }
      break;
    }
    
  }
  static LetterPack decodeLetterPack(List <String> letterSetList){
    LetterPack tempLP;
    String letterPackName = "";
    LetterSet tempLS1;
    LetterSet tempLS2;
    LetterSet tempLS3;
    int index1;
    int index2;
    int index3;
    String letterSetName1 = "";
    String letterSetName2 = "";
    String letterSetName3 = "";
    int position1 = 0;
    int position2 = 0;
    int position3 = 0;
    List<String> lettersList1 = [];
    List<String> lettersList2 = [];
    List<String> lettersList3 = [];
    int count = 0;
    
    for(int i =0; i<letterSetList.length; i++){
      //if the first character of the string is a #, then the string is the name of a letter set
       if(letterSetList[i][0] == "#"){
         count++;
         if(count == 1){
           index1 = i;
           letterSetName1 = letterSetList[i].substring(1,letterSetList[i].length);         
           position1 = int.tryParse(letterSetList[i+1]);
           //if the sets were encoded using old constructor
           if (position1 == null){
             position1 = stringToPositionInt(letterSetList[i+1]);
           }
         }
         if(count == 2){
           index2 = i;
           letterSetName2 = letterSetList[i].substring(1,letterSetList[i].length);
           position2 = int.tryParse(letterSetList[i+1]);
           //if the sets were encoded using old constructor
           if (position2 == null){
             position2 = stringToPositionInt(letterSetList[i+1]);
           }
         }
         if(count == 3){
           index3 = i;
           letterSetName3 = letterSetList[i].substring(1,letterSetList[i].length);
           position3 = int.tryParse(letterSetList[i+1]);
           //if the sets were encoded using old constructor
           if (position3 == null){
             position3 = stringToPositionInt(letterSetList[i+1]);
           }
         }
       }
    }
    letterPackName = letterSetList[0];
    lettersList1 = letterSetList.sublist(index1+2, index2);
    lettersList2 = letterSetList.sublist(index2+2, index3);
    lettersList3 = letterSetList.sublist(index3+2);
    
    tempLS1 = new LetterSet(letterSetName1, position1, lettersList1);
    tempLS2 = new LetterSet(letterSetName2, position2, lettersList2);
    tempLS3 = new LetterSet(letterSetName3, position3, lettersList3);
    tempLP = new LetterPack(letterPackName, tempLS1, tempLS2, tempLS3);
    return tempLP;

  }
  //decodeAll will take allData and update allPacks.
  static void decodeAll(){
    //allPacks is a list of letterpacks
    allPacks.clear();
    //allData is a list of stringLists
    //decodeLetterPack converts stringList into a letterPack
    for (int i=0; i<allData.length; i++){
      allPacks.add(decodeLetterPack(allData[i]));
    }
  }
  
}
//binary representation of position
const int beginning = 1;
const int middle = 2;
const int end = 4;
const int sides = 5;
const int latterHalf = 6;
const int all = 7;
LetterSet singleConsonantsBeginning = LetterSet("Single Consonants", beginning, ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "qu", "r", "s", "t", "v", "w", "x", "y", "z"]);  
LetterSet singleConsonantsEnding = LetterSet("Single Consonants", end, ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "x", "y", "z"]);
LetterSet hBrothers = LetterSet("H Brothers", sides, ["ch", "ph", "sh", "th", "wh"]);
LetterSet beginningBlends = LetterSet("Beginning Blends", beginning, ["bl", "br", "cl", "cr", "dr", "fl", "fr", "gl", "gr", "pl", "pr", "sc", "scr", "shr", "sk", "sl", "sm", "sn", "sp", "spl", "spr", "squ", "st", "str", "sw", "thr", "tr", "tw"]);
LetterSet shortVowelPointers = LetterSet("Short Vowel Pointers", latterHalf, ["ck", "dge", "tch", "ff", "ll", "ss", "zz"]);
LetterSet endingBlends = LetterSet("Ending Blends", end, ["sk", "sp", "st", "ct", "ft", "lk", "lt", "mp", "nch", "nd", "nt", "pt"]);
LetterSet magicEEnding = LetterSet("Magic E", end, ["be", "ce", "de", "fe", "ge", "ke", "le", "me", "ne", "pe", "se", "te"]);
LetterSet closedSyllable = LetterSet("Closed Syllable", middle, ["a", "e", "i", "o", "u"]);
LetterSet openSyllable = LetterSet("Open Syllable", middle, ["a", "e", "i", "o", "u"]);
LetterSet magicEMiddle = LetterSet("Magic E", middle, ["a", "e", "i", "o", "u"]);
LetterSet controlledR = LetterSet("Controlled R", middle, ["ar", "er", "ir", "or", "ur"]);
LetterSet shortVowelExceptions = LetterSet("Short Vowel Exceptions", middle, ["ang", "ank", "ild", "ind", "ing", "ink", "old", "oll", "olt", "ong", "onk", "ost", "ung", "unk"]);
LetterSet vowelTeamBasic = LetterSet("Vowel Team Basic", middle, ["ai", "ay", "ea", "ee", "igh", "oa", "oy"]);
LetterSet vowelTeamIntermediate = LetterSet("Vowel Team Intermediate", middle, ["aw", "eigh", "ew", "ey", "ie", "oe", "oi", "oo", "ou", "ow"]);
LetterSet vowelTeamAdvanced = LetterSet("Vowel Team Advanced", middle, ["aw", "eigh", "ew", "ey", "ie", "oe", "oi", "oo", "ou", "ow"]);
LetterSet vowelA = LetterSet("Vowel A", middle, ["al", "all", "wa", "al", "all", "wa"]);
LetterSet empty = LetterSet("Empty", all, [" ", " ", " ", " "]);
  
List<LetterSet> allSets = [singleConsonantsBeginning, singleConsonantsEnding,  hBrothers, beginningBlends, endingBlends, magicEEnding, closedSyllable, openSyllable, magicEMiddle, shortVowelPointers,  controlledR, shortVowelExceptions, vowelTeamBasic, vowelTeamIntermediate, vowelTeamAdvanced, vowelA, empty];

LetterPack standardClosed = LetterPack("Standard (Closed Syllable)", singleConsonantsBeginning, closedSyllable, singleConsonantsEnding);
LetterPack standardOpen = LetterPack("Standard (Open Syllable)", singleConsonantsBeginning, openSyllable, singleConsonantsEnding);
LetterPack blendingDemo = LetterPack("Blending Demo", LetterSet("Bl",  beginning, ["bl"]), LetterSet("e", middle, ["E"]), LetterSet("Nd", beginning, ["nd"]));
  
List<LetterPack> defaultPacks = [standardClosed, standardOpen, blendingDemo];
List<LetterPack> allPacks = [standardClosed, standardOpen, blendingDemo];

var letterPackMap = {"Standard (Closed Syllable)": standardClosed, "Standard (Open Syllable)": standardOpen, "Blending Demo": blendingDemo};
String letterPackName = "";

LetterSet selectedBeginningSet;
LetterSet selectedMiddleSet;
LetterSet selectedEndSet;
bool firstBuild = true;
bool isLargeScreen;
bool isDarkModeOn;
int colorChipIndex = 0;


//binary representation of mode
const int light = 4;
const int auto = 2;
const int dark = 1;

int currentMode = 2;
//light (4): 100
//auto  (2): 010
//dark  (1): 001

//change variable name
LetterSet mid;


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
          /*actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: (){
                /*Navigator.push(
                  context,
                  FadeRoute(page: MyHomePage()),
                );*/
                Navigator.of(context).pop();
              }
            ),
          ],*/
       );
        },
       
      barrierDismissible: true,
      );

      });
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
                    //child: Text("Version 1.0")
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
  Future<void> _launchURL() async {
  const url = 'http://www.dyslexicmindset.com';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
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
        _launchURL(); 
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
          
          mid = beginningSetsList[index];
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
          mid = middleSetsList[index];
            Navigator.push(
              context,
              //pass letterset index
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
          mid = endSetsList[index];
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
      children: [
      ],
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
  }
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                Container(
                  margin: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10,),
                        child: InputChip(
                    selected: true,
                    label: Container(
                      width: SizeConfig.screenHeight * 0.4,
                      margin: EdgeInsets.all(10),
                      child:  
                        Text(mid.name,
                            style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 2, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                    ),
                    showCheckmark: false,
                    deleteButtonTooltipMessage: "Edit",
                    onDeleted: () {
                    },
                    deleteIcon: Icon(SFSymbols.pencil,
                      size: SizeConfig.safeBlockHorizontal * 3,
                      color: currentColor,
                    ),
                    onPressed: () {
                      setState(() {
                        //_defaultEndChoiceIndex = index;
                      // print("defaultindex: $defaultIndex");
                      // print("listbuilder: $listBuilderIndex");
                      });
                    },
      
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))),
            selectedColor: currentColor.withOpacity(0.3),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: currentColor),
            )
        ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(30),
                  width: SizeConfig.screenWidth * 0.35,
                  height: SizeConfig.screenHeight,
                  
                  child: gridView(itemWidth, itemHeight),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
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
 Widget gridView(double width, double height) {
    return  GridView.count(
      // Create a grid with 3 columns. If you change the scrollDirection to
      // horizontal, this produces 3 rows.
      crossAxisCount: 3,
      childAspectRatio: (width / height),
      // Generate allPacks.length amount widgets that display their index in the List.
      children: List.generate(mid.letters.length + 1 + mid.lettersToAdd.length, (index) {
       
        //last element of gridview should be a textformfield
        if(index == mid.letters.length + mid.lettersToAdd.length){
          return Container(
            margin: EdgeInsets.only(top: 20, right: 5, left: SizeConfig._safeAreaVertical + 10, bottom: 5),
         
            decoration: BoxDecoration(
          
          ),
            child:TextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),],
              style: TextStyle(color: colorsList[colorChipIndex], fontWeight: FontWeight.w600, fontSize: SizeConfig.safeBlockHorizontal * 3),
              onFieldSubmitted: (String input){

            setState(() {
              //when text is submitted to the textformfield, the letters are added to lettersToAdd list of the selected letterset
              mid.lettersToAdd.add(input);
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
        else if(mid.letters.length-1<index && index <mid.letters.length + mid.lettersToAdd.length){
          return Container(
            margin: EdgeInsets.only(top: 5, right: 5, left: SizeConfig._safeAreaVertical + 10, bottom: 5),
            child: FilterChip(
              label: Container(
                margin: EdgeInsets.all(0),
                width: 50,
                height: 50,
                child: Center(
                //fit: BoxFit.fitWidth,
                child: AutoSizeText(mid.lettersToAdd[index-mid.letters.length],
                overflow: TextOverflow.visible,
                  style: TextStyle(color: colorsList[colorChipIndex], 
                  fontSize: SizeConfig.safeBlockHorizontal * 3, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,),
              ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: !mid.lettersToRemove.contains(mid.letters[index-mid.letters.length]) == true ? colorsList[colorChipIndex] : Colors.transparent,
                  ),
                ),
              selected: !mid.lettersToRemove.contains(mid.lettersToAdd[index-mid.letters.length]),
              selectedColor: selectedColorsList[colorChipIndex],
              backgroundColor: Color(0xFF5c6464),
              showCheckmark: false,
              onSelected: (bool selected) {
                setState(() {
                  if(selected){
                    //not selected yet, you are selecting now
                    //(undoing the remove) you do not want to remove this letter from the letter set, so remove it form removeMiddleLetterList
                    mid.lettersToRemove.remove(mid.lettersToAdd[index-mid.letters.length]);
                  }
                  else{
                    //already selected, you are deselecting now
                    //adding letter you want to remove into removeMiddleLetterList
                    mid.lettersToRemove.add(mid.lettersToAdd[index-mid.letters.length]); 
                  }
                });
              }
            )
            );
        }
        else{
          return Container(
            
            margin: EdgeInsets.only(top: 5, right: 5, left: SizeConfig._safeAreaVertical + 10, bottom: 5),
            child: FilterChip(
              selected: !mid.lettersToRemove.contains(mid.letters[index]),
              label:  Container(
                margin: EdgeInsets.all(0),
                width: 50,
                height: 50,
                child: Center(
                  child: AutoSizeText(mid.letters[index],
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
                    color: !mid.lettersToRemove.contains(mid.letters[index]) == true ? colorsList[colorChipIndex] : Colors.transparent,
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
                    mid.lettersToRemove.remove(mid.letters[index]);
                  }
                  else{
                    //already selected, you are deselecting now
                    mid.lettersToRemove.add(mid.letters[index]);
                   
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