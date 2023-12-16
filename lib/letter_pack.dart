import 'letter_set.dart';
import 'config/global_variables.dart';
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