import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'dart:ui';

import '../letter_set.dart';
import '../config/size_config.dart';
import '../config/global_variables.dart';
import '../screen_transitions.dart';


import 'home_screen.dart' show MyHomePage;
import 'save_screen.dart' show SaveScreen;
import 'customize_letters_screen.dart' show CustomizeLettersScreen;

///----Create Decks Screen----///
class CreateDecksScreen extends StatefulWidget {
  @override
  CreateDecksScreenState createState() => CreateDecksScreenState();
}

/**
 * Create Decks Screen where the user can create and customize a letter pack by selecting different letter sets.
 */
class CreateDecksScreenState extends State<CreateDecksScreen> {
  int _defaultBeginningChoiceIndex = 0;
  int _defaultMiddleChoiceIndex = 1;
  int _defaultEndChoiceIndex = 0;
  List<ChoiceChip> choiceChipList = [];
  static List<LetterSet> beginningSetsList = [];
  static List<LetterSet> middleSetsList = [];
  static List<LetterSet> endSetsList = [];
  static LetterSet tempBeginningSet;
  static LetterSet tempMiddleSet;
  static LetterSet tempEndSet;

  /**
   * Sorts all possible letter sets into three columns: beginning, middle, and end
   * by updating beginningSetsList, middleSetsList, and endSetsList
   */
  void sortChips() {
    beginningSetsList.clear();
    middleSetsList.clear();
    endSetsList.clear();
    letterSetsFromSelectedColumn.clear();
    //go through all the sets, take the ones that are beginning, and put them into a list
    for (int i = 0; i < allSets.length; i++) {
      //using bit masking
      if (allSets[i].positionBinary & 1 > 0) {
        beginningSetsList.add(allSets[i]);
      }
      if (allSets[i].positionBinary & 2 > 0) {
        middleSetsList.add(allSets[i]);
      }
      if (allSets[i].positionBinary & 4 > 0) {
        endSetsList.add(allSets[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    sortChips();
  }

  /**
   * Returns the main components of the Create Decks Screen, along with the home button.
   * TODO: make home button to its own widget
   */
  Widget build(BuildContext context) {
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
                    body: Stack(
                      children: <Widget>[
                        choiceChipRow(),
                        Positioned(
                            bottom: 20,
                            left: 20,
                            child: IconButton(
                              icon: Icon(SFSymbols.house_fill),
                              iconSize: SizeConfig.screenHeight * 0.05,
                              color: colorsList[
                                  colorChipIndex], //Color(0xFF0690d4),
                              onPressed: () {
                                setState(() {
                                  sortChips();
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyHomePage()),
                                );
                              },
                            ))
                      ],
                    ))
              ],
            )));
  }

  bool isLongName(String name) {
    bool isLongName;
    if (name.length > 18) {
      isLongName = true;
    } else {
      isLongName = false;
    }
    return isLongName;
  }

  ///----Build methods for widgets in Create Decks Screen----///
  /**
   * Returns a list view of all choice chips for "beginning" letter sets.
   */
  Widget beginningChoiceChips() {
    return ListView.builder(
      itemCount: beginningSetsList.length,
      //itemExtent: 100,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            //height: 50,
            //width: SizeConfig.screenWidth * 0.25,
            margin: EdgeInsets.only(
              bottom: 10,
            ),
            // padding: EdgeInsets.only(bottom: 10,),
            child: InputChip(
              selected: _defaultBeginningChoiceIndex == index,
              label: Container(
                width: 200,
                margin: EdgeInsets.all(10),
                child: Text(
                  beginningSetsList[index].name,
                  style: TextStyle(
                      fontSize: isLongName(beginningSetsList[index].name)
                          ? SizeConfig.safeBlockHorizontal * 1.6
                          : SizeConfig.safeBlockHorizontal * 2,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ),
              showCheckmark: false,
              deleteButtonTooltipMessage: "Edit",
              onDeleted: () {
                setState(() {
                  _defaultBeginningChoiceIndex = index;
                });
                for (int i = 0; i < beginningSetsList.length; i++) {
                  letterSetsFromSelectedColumn.add(beginningSetsList[i]);
                }
                selLS = beginningSetsList[index];
                Navigator.push(
                  context,
                  //pass letterset index
                  MaterialPageRoute(
                      builder: (context) => CustomizeLettersScreen()),
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

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              selectedColor: currentColor
                  .withOpacity(0.3), //Color(0xFF3478F6).withOpacity(0.3),
              backgroundColor: isDarkModeOn ? Colors.black : Colors.white,
              labelStyle: TextStyle(color: currentColor),
            ));
      },
    );
  }
  /**
   * Returns a list view of all choice chips for "middle" letter sets.
   */
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
                child: Text(
                  middleSetsList[index].name,
                  style: TextStyle(
                      fontSize: isLongName(middleSetsList[index].name)
                          ? SizeConfig.safeBlockHorizontal * 1.6
                          : SizeConfig.safeBlockHorizontal * 2,
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
                for (int i = 0; i < middleSetsList.length; i++) {
                  letterSetsFromSelectedColumn.add(middleSetsList[i]);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomizeLettersScreen()),
                );
              },
              deleteIcon: Icon(
                SFSymbols.pencil,
                color: currentColor,
                size: SizeConfig.safeBlockHorizontal * 2.5,
              ),
              onPressed: () {
                setState(() {
                  _defaultMiddleChoiceIndex = index;
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              selectedColor: currentColor.withOpacity(0.3),
              backgroundColor: isDarkModeOn ? Colors.black : Colors.white,
              labelStyle: TextStyle(color: currentColor),
            ));
      },
    );
  }
  /**
   * Returns a list view of all choice chips for "end" letter sets.
   */
  Widget endChoiceChips() {
    return ListView.builder(
      itemCount: endSetsList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            margin: EdgeInsets.only(
              bottom: 10,
            ),
            child: InputChip(
              selected: _defaultEndChoiceIndex == index,
              label: Container(
                width: 200,
                margin: EdgeInsets.all(10),
                child: Text(
                  endSetsList[index].name,
                  style: TextStyle(
                      fontSize: isLongName(endSetsList[index].name)
                          ? SizeConfig.safeBlockHorizontal * 1.6
                          : SizeConfig.safeBlockHorizontal * 2,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ),
              showCheckmark: false,
              deleteButtonTooltipMessage: "Edit",
              onDeleted: () {
                setState(() {
                  _defaultEndChoiceIndex = index;
                });
                for (int i = 0; i < endSetsList.length; i++) {
                  letterSetsFromSelectedColumn.add(endSetsList[i]);
                }
                selLS = endSetsList[index];
                Navigator.push(
                  context,
                  //pass letterset index
                  MaterialPageRoute(
                      builder: (context) => CustomizeLettersScreen()),
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

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              selectedColor: currentColor
                  .withOpacity(0.3), //Color(0xFF3478F6).withOpacity(0.3),
              backgroundColor: isDarkModeOn ? Colors.black : Colors.white,
              labelStyle: TextStyle(color: currentColor),
            ));
      },
    );
  }
  /**
   * Returns a button that updates the selected letter pack information to 
   * tempBeginningSet, tempMiddleSet, tempEndSet.
   */
  Widget checkmarkButton() {
    return Container(
      //margin: EdgeInsets.only(right: SizeConfig.safeAreaVertical + 20, left: SizeConfig.safeAreaVertical + 20),
      child: IconButton(
        icon: Icon(SFSymbols.checkmark_circle_fill),
        color: colorsList[colorChipIndex], //Color(0xFF00cbfb),
        iconSize: SizeConfig.screenHeight * 0.08,
        onPressed: () {
          setState(() {
            //sortChips();

            selectedBeginningSet =
                beginningSetsList[_defaultBeginningChoiceIndex];
            selectedMiddleSet = middleSetsList[_defaultMiddleChoiceIndex];
            selectedEndSet = endSetsList[_defaultEndChoiceIndex];

            print(selectedMiddleSet.lettersToRemove);
            tempBeginningSet = LetterSet(
                selectedBeginningSet.name,
                selectedBeginningSet.positionBinary,
                selectedBeginningSet.generateCustomLetters());
            tempMiddleSet = LetterSet(
                selectedMiddleSet.name,
                selectedMiddleSet.positionBinary,
                selectedMiddleSet.generateCustomLetters());
            tempEndSet = LetterSet(
                selectedEndSet.name,
                selectedEndSet.positionBinary,
                selectedEndSet.generateCustomLetters());
            //clear lettersToRemove and lettersToAdd

            //HAVE TO DO TO ALL, NOT JUST SELECTED
            for (LetterSet b in beginningSetsList) {
              b.lettersToAdd.clear();
              b.lettersToRemove.clear();
            }
            for (LetterSet m in middleSetsList) {
              m.lettersToAdd.clear();
              m.lettersToRemove.clear();
            }
            for (LetterSet e in endSetsList) {
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
  /**
   * Returns an empty Column for spacing purposes.
   */
  Widget emptyColumn() {
    return Container(
        width: SizeConfig.screenWidth * 0.1,
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.only(
          top: SizeConfig.safeAreaVertical + 20,
          right: 5,
        ),
        child: Column(
          children: [],
        ));
  }

  /**
   * Returns a Column of choice chips for the "beginning" letter sets. 
   */
  Widget column1() {
    return Container(
        width: SizeConfig.screenWidth * 0.25,
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.only(
          top: SizeConfig.safeAreaVertical + 20,
          right: 5,
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text("Column 1",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorsList[colorChipIndex],
                    fontSize: SizeConfig.safeBlockHorizontal * 3,
                  )),
            ),
            Flexible(
              child: beginningChoiceChips(),
            )
          ],
        ));
  }
  /**
   * Returns a Column of choice chips for the "middle" letter sets. 
   */
  Widget column2() {
    return Container(
        width: SizeConfig.screenWidth * 0.25,
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.only(
          top: SizeConfig.safeAreaVertical + 20,
          right: 5,
          left: 5,
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text("Column 2",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorsList[colorChipIndex],
                      fontSize: (SizeConfig.safeBlockHorizontal * 3))),
            ),
            Flexible(
              child: middleChoiceChips(),
            )
          ],
        ));
  }

  /**
   * Returns a Column of choice chips for the "end" letter sets. 
   */
  Widget column3() {
    return Container(
        width: SizeConfig.screenWidth * 0.25,
        height: SizeConfig.screenHeight,
        margin:
            EdgeInsets.only(top: SizeConfig.safeAreaVertical + 20, left: 5),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text("Column 3",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorsList[colorChipIndex],
                    fontSize: (SizeConfig.safeBlockHorizontal * 3),
                  )),
            ),
            Flexible(
              child: endChoiceChips(),
            )
          ],
        ));
  }

  /**
   * Returns a row of columns that display the letter sets and the checkmark button.
   */
  Widget choiceChipRow() {
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