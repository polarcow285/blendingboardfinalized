import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'dart:ui';

import '../letter_set.dart';
import '../config/size_config.dart';
import '../config/global_variables.dart';




///----Customize Letters Screen----///

class CustomizeLettersScreen extends StatefulWidget {
  @override
  _CustomizeLettersState createState() => _CustomizeLettersState();
}

/**
 * Customize Letters Screen where users can add or remove letters to the 
 * letter set that they are currently editing.
 */
class _CustomizeLettersState extends State<CustomizeLettersScreen> {
  /**
   * Controller for the TextFormField.
   */
  final _controller = TextEditingController();

  /**
   * List of background colors to display when a letter is selected
   */
  List<Color> selectedColorsList = [
    Color(0xFF2250be),
    Color(0xffe0353a),
    Colors.orange,
    Color(0xFF315d3a),
    Color(0xFF553777),
    Color(0xFFf13850),
    Color(0xFF6d6e71),
    Color(0xFF217b82)
  ];

  /**
   * Upon initialization, the screen is set to landscape mode
   * and saves the current letter pack name.
   */
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    //print(letterSetsFromSelectedColumn);
  }

  /**
   * Disploses the controller for the text form field.
   */
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /**
   * Returns whether the LetterSet `lset` is selected.
   */
  bool isSelectedChecker(LetterSet lset) {
    //check equality of two lists
    Function eq = const ListEquality().equals;
    bool isAdded = true;
    if (selLS.lettersToAdd.length == 0 || eq(selLS.letters, lset.letters)) {
      isAdded = false;
    } else {
      for (int i = 0; i < lset.letters.length; i++) {
        //if the pack u are making does not have the letters from the set then
        //that set is not selected
        if (!selLS.lettersToAdd.contains(lset.letters[i]) &&
            !selLS.letters.contains(lset.letters[i])) {
          print(lset.letters[i]);
          isAdded = false;
          break;
        }
      }
    }
    return isAdded;
  }

  /**
   * Returns the main components of the Customize Letters Screen.
   */
  Widget build(BuildContext context) {
    final double itemWidth = SizeConfig.screenWidth / 50;
    final double itemHeight = SizeConfig.screenWidth / 50;
    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                backgroundColor: Color(0xFF1b454f),
                body: Stack(children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: currentBackgroundImage,
                              fit: BoxFit.cover)),
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
                    body: Row(
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
                        ]),
                  )
                ]))));
  }

  ///----Build methods for widgets in Customize Letters Screen----///
  
  /**
    * Returns whether `name` is a long name.
    */
  bool isLongName(String name) {
    bool isLongName;
    if (name.length > 18) {
      isLongName = true;
    } else {
      isLongName = false;
    }
    return isLongName;
  }

  /**
   * Returns a column containing the list of letter sets from the column the user selected the letter set from.
   */
  Widget selectedColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            child: selectedColumnChips(),
            width: SizeConfig.screenWidth * 0.5,
            height: SizeConfig.screenHeight * 0.9)
      ],
    );
  }

  /**
   * Returns a list of the letter sets from the column the user selected the letter set from.
   */
  Widget selectedColumnChips() {
    return ListView.builder(
        itemCount: letterSetsFromSelectedColumn.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          //if this is the selected element, make return it
          if (index ==
              letterSetsFromSelectedColumn
                  .indexWhere((element) => element == selLS)) {
            return Container(
                margin: EdgeInsets.only(
                  bottom: 10,
                ),
                child: InputChip(
                  selected: true,
                  label: Container(
                    width: SizeConfig.screenHeight * 0.4,
                    margin: EdgeInsets.all(10),
                    child: Text(
                      selLS.name,
                      style: TextStyle(
                          fontSize: isLongName(selLS.name)
                              ? SizeConfig.safeBlockHorizontal * 1.6
                              : SizeConfig.safeBlockHorizontal * 2,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  showCheckmark: false,
                  deleteButtonTooltipMessage: "Add",
                  onDeleted: () {},
                  deleteIcon: Icon(
                    SFSymbols.pencil,
                    size: SizeConfig.safeBlockHorizontal * 3,
                    color: currentColor,
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10))),
                  selectedColor: currentColor.withOpacity(0.3),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: currentColor),
                ));
          } else {
            return Container(
                margin: EdgeInsets.only(
                  bottom: 10,
                ),
                child: InputChip(
                  label: Container(
                    width: SizeConfig.screenHeight * 0.4,
                    margin: EdgeInsets.all(10),
                    child: Text(
                      letterSetsFromSelectedColumn[index].name,
                      style: TextStyle(
                          fontSize: isLongName(
                                  letterSetsFromSelectedColumn[index].name)
                              ? SizeConfig.safeBlockHorizontal * 1.6
                              : SizeConfig.safeBlockHorizontal * 2,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  showCheckmark: false,
                  deleteButtonTooltipMessage: "Add",
                  onDeleted: () {},
                  deleteIcon: Icon(
                    SFSymbols.plus,
                    size: SizeConfig.safeBlockHorizontal * 3,
                    color: currentColor,
                  ),
                  selected:
                      isSelectedChecker(letterSetsFromSelectedColumn[index]),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        //not selected yet, you are selecting now
                        //adding the letters
                        for (int i = 0;
                            i <
                                letterSetsFromSelectedColumn[index]
                                    .letters
                                    .length;
                            i++) {
                          //no repeat letters
                          if (!selLS.letters.contains(
                              letterSetsFromSelectedColumn[index].letters[i])) {
                            selLS.lettersToAdd.add(
                                letterSetsFromSelectedColumn[index].letters[i]);
                          }
                        }
                      } else {
                        //already selected, you are deselecting now
                        for (int i = 0;
                            i <
                                letterSetsFromSelectedColumn[index]
                                    .letters
                                    .length;
                            i++) {
                          selLS.lettersToAdd.remove(
                              letterSetsFromSelectedColumn[index].letters[i]);
                        }
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10))),
                  selectedColor: currentColor.withOpacity(0.3),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: currentColor),
                ));
          }
        });
  }

  /**
   * Returns a gridview of all the letters in the selected letter set, including letters added by the user
   * and a TextFormField for users to add new letters.
   */
  Widget gridView(double width, double height) {
    return GridView.count(
      // Create a grid with 3 columns. If you change the scrollDirection to
      // horizontal, this produces 3 rows.
      crossAxisCount: 3,
      childAspectRatio: (width / height),
      // Generate allPacks.length amount widgets that display their index in the List.
      children: List.generate(
          selLS.letters.length + 1 + selLS.lettersToAdd.length, (index) {
        //last element of gridview should be a textformfield
        if (index == selLS.letters.length + selLS.lettersToAdd.length) {
          return Container(
            margin: EdgeInsets.only(
                top: 20,
                right: 5,
                left: SizeConfig.safeAreaVertical + 10,
                bottom: 5),
            decoration: BoxDecoration(),
            child: TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
              ],
              style: TextStyle(
                  color: colorsList[colorChipIndex],
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.safeBlockHorizontal * 3),
              onFieldSubmitted: (String input) {
                setState(() {
                  //when text is submitted to the textformfield, the letters are added to lettersToAdd list of the selected letterset
                  selLS.lettersToAdd.add(input);
                  _controller.clear();
                });
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: "+",
                  hintStyle: TextStyle(
                      color: colorsList[colorChipIndex],
                      fontSize: SizeConfig.safeBlockHorizontal * 3),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: SizeConfig.screenWidth * 0.02,
                  ),
                  fillColor: Colors.black.withOpacity(0.3),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none)),
              controller: _controller,
            ),
          );
        }
        //sorting letters that were manually added, putting their filterchips after original letters
        else if (selLS.letters.length - 1 < index &&
            index < selLS.letters.length + selLS.lettersToAdd.length) {
          return Container(
              margin: EdgeInsets.only(
                  top: 5,
                  right: 5,
                  left: SizeConfig.safeAreaVertical + 10,
                  bottom: 5),
              child: FilterChip(
                  label: Container(
                    margin: EdgeInsets.all(0),
                    width: 50,
                    height: 50,
                    child: Center(
                      //fit: BoxFit.fitWidth,
                      child: AutoSizeText(
                        selLS.lettersToAdd[index - selLS.letters.length],
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                            color: colorsList[colorChipIndex],
                            fontSize: SizeConfig.safeBlockHorizontal * 3,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: !selLS.lettersToRemove.contains(selLS.lettersToAdd[
                                  index - selLS.letters.length]) ==
                              true
                          ? colorsList[colorChipIndex]
                          : Colors.transparent,
                    ),
                  ),
                  selected: !selLS.lettersToRemove.contains(
                      selLS.lettersToAdd[index - selLS.letters.length]),
                  selectedColor: selectedColorsList[colorChipIndex],
                  backgroundColor: Color(0xFF5c6464),
                  showCheckmark: false,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        //not selected yet, you are selecting now
                        //(undoing the remove) you do not want to remove this letter from the letter set, so remove it form removeMiddleLetterList
                        selLS.lettersToRemove.remove(
                            selLS.lettersToAdd[index - selLS.letters.length]);
                      } else {
                        //already selected, you are deselecting now
                        //adding letter you want to remove into removeMiddleLetterList
                        selLS.lettersToRemove.add(
                            selLS.lettersToAdd[index - selLS.letters.length]);
                      }
                    });
                  }));
        } else {
          //print("current index (original): " + index.toString());
          return Container(
              margin: EdgeInsets.only(
                  top: 5,
                  right: 5,
                  left: SizeConfig.safeAreaVertical + 10,
                  bottom: 5),
              child: FilterChip(
                  selected:
                      !selLS.lettersToRemove.contains(selLS.letters[index]),
                  label: Container(
                      margin: EdgeInsets.all(0),
                      width: 50,
                      height: 50,
                      child: Center(
                        child: AutoSizeText(
                          selLS.letters[index],
                          overflow: TextOverflow.visible,
                          //if the letter is not part of the lettersToRemove list, it should be selected
                          style: TextStyle(
                              color: colorsList[colorChipIndex],
                              //color: !mid.lettersToRemove.contains(mid.letters[index]) == true ?  Color(0xFF78cbff): Color(0xFF78c9ff),
                              fontSize: SizeConfig.safeBlockHorizontal * 3,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: !selLS.lettersToRemove
                                  .contains(selLS.letters[index]) ==
                              true
                          ? colorsList[colorChipIndex]
                          : Colors.transparent,
                    ),
                  ),
                  selectedColor: selectedColorsList[
                      colorChipIndex], //Colors.orange,//Color(0xFF2250be),
                  backgroundColor: Color(0xFF5c6464),
                  showCheckmark: false,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        //not selected yet, you are selecting now
                        //undoing the remove
                        selLS.lettersToRemove.remove(selLS.letters[index]);
                      } else {
                        //already selected, you are deselecting now
                        selLS.lettersToRemove.add(selLS.letters[index]);
                      }
                    });
                  }));
        }
      }),
    );
  }
}