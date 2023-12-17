import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'dart:ui';

import '../config/size_config.dart';
import '../config/global_variables.dart';
import '../letter_pack.dart';
import '../screen_transitions.dart';

import 'board_screen.dart' show BoardScreen;
import 'create_decks_screen.dart' show CreateDecksScreenState;

class SaveScreen extends StatefulWidget {
  @override
  SaveScreenState createState() => SaveScreenState();
}

class SaveScreenState extends State<SaveScreen> {
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

  static saveAll() async {
    numberOfLetterPacks++;
    LetterPack.encodeAll();
    print("encode all success!");
    await _saveInt(numberOfLetterPacks);
    print("saveInt success!");
    //goes through allData (list of string lists), which saves each letter pack
    for (int i = 0; i < numberOfLetterPacks; i++) {
      await _saveLetterPack(allData[i], i.toString());
    }
    print('Saved All');
    print(numberOfLetterPacks);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
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
                    resizeToAvoidBottomInset: false,
                    backgroundColor: Colors.transparent,
                    body: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              top: SizeConfig.safeAreaVertical + 20,
                              bottom: 5),
                          child: Text(
                            "Save Your Deck?",
                            style: TextStyle(
                                color: colorsList[
                                    colorChipIndex], //Color(0xFF1079c4),
                                fontWeight: FontWeight.w700,
                                fontSize: SizeConfig.safeBlockHorizontal * 4),
                          ),
                        ),
                        textSaveRow(),
                        skipSaveButton(),
                      ],
                    ))
              ],
            )));
  }

  ///----Build methods for widgets in Save Screen----///
  Widget textSaveRow() {
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

  Widget textFormField() {
    return Container(
        width: SizeConfig.screenWidth * 0.3,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Form(
            key: _formKey,
            child: TextFormField(
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              textAlign: TextAlign.center,
              controller: _controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: SizeConfig.screenWidth * 0.02,
                ),
                fillColor: Colors.white.withOpacity(0.3),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none),
                hintText: 'Deck Name',
                hintStyle: TextStyle(
                    color: Color(0xFF373737),
                    fontWeight: FontWeight.w500,
                    fontSize: SizeConfig.safeBlockHorizontal * 2.5),
              ),
            )));
  }

  Widget saveButton() {
    return Container(
      margin: EdgeInsets.all(20),
      child: IconButton(
        icon: Icon(SFSymbols.checkmark_circle_fill),
        iconSize: SizeConfig.screenWidth * 0.05,
        color: colorsList[colorChipIndex],
        onPressed: () {
          if (_formKey.currentState.validate()) {
            setState(() {
              allPacks.add(new LetterPack(
                  _controller.text,
                  CreateDecksScreenState.tempBeginningSet,
                  CreateDecksScreenState.tempMiddleSet,
                  CreateDecksScreenState.tempEndSet));
              letterPackName = _controller.text;
              //put new letterPack into letterPackMap
              letterPackMap[allPacks.last.name] = allPacks.last;
              saveAll();
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
        child: Text(
          "Skip, Don't Save Deck",
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: colorsList[colorChipIndex], //Color(0xFF0094c8),
              fontWeight: FontWeight.w500,
              fontSize: SizeConfig.safeBlockHorizontal * 2),
        ),
        onPressed: () async {
          //Load the discard pack to the blending board
          discardPack = LetterPack(
              "discardPack",
              CreateDecksScreenState.tempBeginningSet,
              CreateDecksScreenState.tempMiddleSet,
              CreateDecksScreenState.tempEndSet);
          letterPackName = "discardPack";
          letterPackMap["discardPack"] = discardPack;

          //Save the discard letter pack
          List<String> tempEncodedStringList = [];
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