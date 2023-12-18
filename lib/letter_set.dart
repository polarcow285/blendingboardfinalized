/**
 * LetterSet class representing a set of letters. In a Blending Board, when three letter sets are 
 * placed side by side, the letters form a word. 
 */
class LetterSet {
  //The name of the letter set. Eg "Single Consonants".
  String name;

  //The placement of the letter set represented in the numerical value of its binary form.
  int positionBinary; //for 3 columns

  //The letters in the letter set.
  List<String> letters;

  //The letters to be removed from the letter set during user customization.
  List<String> lettersToRemove;

  //The letters to be added from the letter set during user customization.
  List<String> lettersToAdd;

  /**
   * Create a new LetterSet with the name `nameString`, the position given by `positionInt`, and
   * the letters in `letterList`.
   */
  LetterSet(String nameString, int positionInt, List<String> letterList) {
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

  /**
   * Return a list of user-edited letters
   */
  List<String> generateCustomLetters() {
    List<String> tempList = [];

    //copy letters from original letter set to edited one
    for (int i = 0; i < letters.length; i++) {
      tempList.add(letters[i]);
    }

    //removing letters
    for (int j = 0; j < lettersToRemove.length; j++) {
      tempList.remove(lettersToRemove[j]);
    }

    //adding letters
    for (int k = 0; k < lettersToAdd.length; k++) {
      tempList.add(lettersToAdd[k]);
    }
    //if the user has deleted all the letters, input a blank space into the list
    //this prevents a crash when the BoardScreen tries to load
    if (tempList.length == 0) {
      tempList.add(" ");
    }
    return tempList;
  }

  /**
   * Edits `stringList` with the encoded data of this letter set. 
   * Uses "#" as a delimiter.
   */
  void dataEncode(List<String> stringList) {
    stringList.add("#" + name);
    stringList.add("$positionBinary");
    for (int i = 0; i < letters.length; i++) {
      stringList.add(letters[i]);
    }
  }

  /**
   * Returns a string of the encoded data of this letter set
   * in the way that the ios version of Blending Board encodes 
   * the data for QR transmission
   */
  String dataEncodeiOS() {
    String encodedLetterSet = "";
    //stringList.add("{\"$position\":");
    encodedLetterSet += ("{\"name\":");
    encodedLetterSet += ("\"$name\",");
    encodedLetterSet += ("\"position\":");
    encodedLetterSet += ("$positionBinary");
    encodedLetterSet += (",");
    encodedLetterSet += ("\"letters\":");
    encodedLetterSet += ("[");

    for (int i = 0; i < letters.length; i++) {
      if (i == letters.length - 1) {
        encodedLetterSet += ("\"${letters[i]}\"]}");
      } else {
        encodedLetterSet += ("\"${letters[i]}\",");
      }
    }
    return encodedLetterSet;
  }

  /**
   * Helper method that prints the fields of this letter set.
   */
  void letterSetInfo() {
    print(name);
    print(positionBinary);
    print(letters);
  }
}
