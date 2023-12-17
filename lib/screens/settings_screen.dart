import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import '../screen_transitions.dart';
import '../config/size_config.dart';
import '../config/global_variables.dart';

import 'home_screen.dart' show MyHomePage;


///----Settings Screen----///

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int modesPickerValue = 0;
  Map<int, Widget> modesMap = <int, Widget>{
    light: Text("Light"),
    auto: Text("Auto"),
    dark: Text("Dark")
  };
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    if (isDarkModeOn) {
      modesPickerValue = dark;
    } else {
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
                  child: settingsColumn(),
                ),
              ])),
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

                  Navigator.push(context, FadeRoute(page: MyHomePage()));
                },
              )),
        ]));
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

  Widget modePicker() {
    return CupertinoSlidingSegmentedControl(
        groupValue: currentMode,
        children: modesMap,
        thumbColor: isDarkModeOn ? Colors.grey.withOpacity(0.3) : Colors.white,
        onValueChanged: (i) {
          setState(() {
            currentMode = i;
            if (i == light) {
              //light mode is selected
              isDarkModeOn = false;
              modesMap.update(
                  light,
                  (var val) => val =
                      Text("Light", style: TextStyle(color: Colors.black)));
              modesMap.update(
                  auto,
                  (var val) => val =
                      Text("Auto", style: TextStyle(color: Colors.black)));
              modesMap.update(
                  dark,
                  (var val) => val =
                      Text("Dark", style: TextStyle(color: Colors.black)));
            } else if (i == auto) {
              //auto mode is selected
              var brightness =
                  SchedulerBinding.instance.window.platformBrightness;
              isDarkModeOn = brightness == Brightness.dark;
              if (isDarkModeOn) {
                modesMap.update(
                    light,
                    (var val) => val =
                        Text("Light", style: TextStyle(color: Colors.white)));
                modesMap.update(
                    auto,
                    (var val) => val =
                        Text("Auto", style: TextStyle(color: Colors.white)));
                modesMap.update(
                    dark,
                    (var val) => val =
                        Text("Dark", style: TextStyle(color: Colors.white)));
              } else {
                modesMap.update(
                    light,
                    (var val) => val =
                        Text("Light", style: TextStyle(color: Colors.black)));
                modesMap.update(
                    auto,
                    (var val) => val =
                        Text("Auto", style: TextStyle(color: Colors.black)));
                modesMap.update(
                    dark,
                    (var val) => val =
                        Text("Dark", style: TextStyle(color: Colors.black)));
              }
            } else if (i == dark) {
              //dark mode is selected
              isDarkModeOn = true;
              modesMap.update(
                  light,
                  (var val) => val =
                      Text("Light", style: TextStyle(color: Colors.white)));
              modesMap.update(
                  auto,
                  (var val) => val =
                      Text("Auto", style: TextStyle(color: Colors.white)));
              modesMap.update(
                  dark,
                  (var val) => val =
                      Text("Dark", style: TextStyle(color: Colors.white)));
            }
          });
        });
  }

  Widget settingsColumn() {
    return Container(
        width: SizeConfig.screenWidth * 0.6,
        height: SizeConfig.screenHeight,
        //margin: EdgeInsets.only(top: SizeConfig.safeAreaVertical + 20),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 50),
              child: Text("Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorsList[colorChipIndex],
                    fontSize: (SizeConfig.safeBlockHorizontal * 3),
                  )),
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
        ));
  }

  Widget modeRow() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
        margin: EdgeInsets.only(right: 20),
        child: Text("Dark Mode",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: SizeConfig.safeBlockHorizontal * 2)),
      ),
      Container(
        width: SizeConfig.screenWidth * 0.4,
        child: modePicker(),
      )
    ]);
  }

  Widget colorChipsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 20),
          child: Text("Theme Color",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.safeBlockHorizontal * 2)),
        ),
        Container(
          width: SizeConfig.screenWidth * 0.4,
          child: colorChips(),
        )
      ],
    );
  }

  Widget colorChips() {
    return ListView.builder(
        itemCount: themeColorsList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          //if this is the last element, make it a star
          if (index == themeColorsList.length - 1) {
            return Container(
                child: ChoiceChip(
              label: Icon(SFSymbols.star_circle_fill,
                  color: themeColorsList[index],
                  size: SizeConfig.safeBlockHorizontal * 4),
              selected: colorChipIndex == index,
              onSelected: (selected) {
                setState(() {
                  colorChipIndex = index;
                  currentColor = themeColorsList[index];
                  currentBackgroundImage = backgroundImagesList[index];
                  currentBrainLogoImage = brainLogoImagesList[index];
                });
              },
            ));
          } else {
            return Container(
                child: ChoiceChip(
              label: Icon(SFSymbols.circle_fill,
                  color: themeColorsList[index],
                  size: SizeConfig.safeBlockHorizontal * 4),
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
            ));
          }
        });
  }
}