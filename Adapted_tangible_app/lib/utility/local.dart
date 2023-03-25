import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';

///Methods relating to files in the local storage

///Related enum for objects
enum Objects {pendant, cube, card}

///Translator function from string to enum for Objects
Objects? getEnumObject(String obj) {
  if (obj == "cube"){
    return Objects.cube;
  }
  if (obj == "pendant") {
    return Objects.pendant;
  }
  if (obj == "card") {
    return Objects.card;
  }
  return null;
}

///Translator function from enum to string for Objects
String getStringObject(Objects? obj) {
  if (obj == Objects.cube){
    return "cube";
  }
  if (obj == Objects.pendant){
    return "pendant";
  }
  if (obj == Objects.card){
    return "card";
  }
  return "";
}

///Utility functions for local storage

///Returns the local path to internal app storage
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

///Returns the local path to the first start file
Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/init.txt');
}

///Simultaneously checks file exists and returns the object stored
///(Returns "None" if no file)
Future<String> getObject() async {
  try{
    final f = await _localFile;
    final contents = await f.readAsString();
    String obj = contents.split(",")[0];
    return obj;
  }
  catch (e) {
    return "None";
  }
}

///Simultaneously checks file exists and returns the participant num stored
///(Returns -1 if no file)
Future<int> getParticipantNum() async {
  try{
    final f = await _localFile;
    final contents = await f.readAsString();
    int num = int.parse(contents.split(",")[1]);
    return num;
  }
  catch (e) {
    return -1;
  }
}

///Create and write the object chosen and participant number specified to file
Future<File> writeInitFile(String obj, int? num) async {
  final f = await _localFile;
  return f.writeAsString(obj + "," + num.toString());
}

///Get Withdrawn status from file storage
Future<bool> getWithdrawn() async {
  final path = await _localPath;
  try {
    final f = File('$path/inactive.txt');
    final contents = await f.readAsString();
    bool active = contents.isEmpty; //If file is empty, then user still active
    return active;
  }
  catch (e) {
    return true; //If failed to read file, doesn't exist, hence active
  }
}

///Set Withdrawn status in file storage
Future<File> setWithdrawn() async {

  //Write locally
  final path = await _localPath;
  final f = File('$path/inactive.txt');
  return f.writeAsString('false');
}

///Get the status of the study - ie false indicate still in orientation, true indicted study live
Future<bool> getLiveStatus() async {
  final path = await _localPath;
  try {
    final f = File('$path/live.txt');
    final contents = await f.readAsString();
    bool live = contents.isNotEmpty; //If file is not empty, then study is live, else still in orientation
    return live;
  }
  catch (e){
    return false; //If file doesn't exist, then still in orientation
  }
}

///Set the status of the study - see above
Future<File> setLiveStatus() async {
  final path = await _localPath;
  final f = File('$path/live.txt');
  return f.writeAsString('true');
}