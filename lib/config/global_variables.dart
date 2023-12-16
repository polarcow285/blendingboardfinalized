import 'package:flutter/material.dart';
import '../letter_set.dart';
import '../letter_pack.dart';

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
LetterSet magicEMiddle = LetterSet("Magic E", middle, ["a", "e", "i", "o", "u", "y"]);
LetterSet controlledR = LetterSet("Controlled R", middle, ["ar", "er", "ir", "or", "ur"]);
LetterSet shortVowelExceptions = LetterSet("Short Vowel Exceptions", middle, ["ang", "ank", "ild", "ind", "ing", "ink", "old", "oll", "olt", "ong", "onk", "ost", "ung", "unk"]);
LetterSet vowelTeamBasic = LetterSet("Vowel Team Basic", middle, ["ai", "ay", "ea", "ee", "igh", "oa", "oy"]);
LetterSet vowelTeamIntermediate = LetterSet("Vowel Team Intermediate", middle, ["aw", "ei", "eigh", "ew", "ey", "ie", "oe", "oi", "oo", "ou", "ow"]);
LetterSet vowelTeamAdvanced = LetterSet("Vowel Team Advanced", middle, ["aw", "ei", "eigh", "ew", "ey", "ie", "oe", "oi", "oo", "ou", "ow"]);
LetterSet vowelA = LetterSet("Vowel A", middle, ["al", "all", "wa"]);
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

//selected LetterSet
LetterSet selLS;
List <LetterSet> letterSetsFromSelectedColumn = [];
