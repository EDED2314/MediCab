import 'dart:convert';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import 'package:medicab/api/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

String wothoutbase = "192.168.86.111:5600";
String base = "http://$wothoutbase";
// String username = "EDED2314";

Future<String> readUsername() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String action = prefs.getString('username') ?? "user123";
  return action;
}

Map<String, String> convertToMap(dynamic item) {
  if (item is Map<String, dynamic>) {
    Map<String, String> convertedMap = {};
    item.forEach((key, value) {
      convertedMap[key] = value.toString();
    });
    return convertedMap;
  }
  return {};
}

String convertToString(dynamic item) {
  return item.toString();
}

// Future<Map<String, dynamic>> loadData(String ending) async {
//   // Uri url = Uri(
//   //   host: "192.168.86.189:5600",
//   //   path: ending,
//   //   scheme: "http",
//   //   queryParameters: map,
//   // );
//   // for post request^
//   final response = await http.get(Uri.parse(base + ending));
//   if (response.statusCode == 200) {
//     return json.decode(response.body);
//   } else {
//     if (kDebugMode) {
//       print("[DEBUG loadData]: failed to get data");
//     }
//     return {};
//   }
// }

// void test(String username) async {
//   Map<String, dynamic> data =
//       await loadData("/api/database/medicines/$username");
//   if (kDebugMode) {
//     print(data);
//   }
// }

Future<List<String>> sendImageAndGetMedicine(
    String username, String imagePath) async {
  http.MultipartRequest request =
      http.MultipartRequest('POST', Uri.parse("$base/api/detect/$username"));

  request.files.add(
    await http.MultipartFile.fromPath(
      'images',
      imagePath,
    ),
  );
  await request.send();

  for (int i = 0; i < 1000; i++) {}

  final response = await http.get(Uri.parse('$base/api/detect/$username'));

  //print(jsonDecode(response.body));
  // print('HI');
  List<dynamic> detections = json.decode(response.body)["detections"];

  // print('HI');
  List<String> convertedList =
      detections.map((item) => convertToString(item)).toList();
  //print('HI');
  if (kDebugMode) {
    print(jsonDecode(response.body));
    print(convertedList);
  }

  return convertedList;
  // cool = Data.fromJson(jsonDecode(response.body));
}

Future<List<Map<String, String>>> getMeds(String username) async {
  // Map<String, dynamic> js = json.decode("{\"asdfads\":\"asdfdasf\"}");
  // print(js);
//  print("hi");
// print("$base/api/database/medicines/$username");
  final response =
      await http.get(Uri.parse("$base/api/database/medicines/$username"));

  // print(json.decode(response.body));

  List<dynamic> meds = json.decode(response.body)["medicines"];
  List<Map<String, String>> convertedList =
      meds.map((item) => convertToMap(item)).toList();

  // print(convertedList.runtimeType);
  // return json.decode(response.body)["medicines"];
  return convertedList;
}

Future<void> updateMedList(
    String username, List<Map<String, String>> payload) async {
  String jsonString = jsonEncode({"data": payload});

  // print(jsonString);

  var response = await http.post(Uri.parse("$base/medsapi/infos/$username"),
      headers: {'Content-Type': 'application/json'}, body: jsonString);

  print('API response: ${response.body}');

  return;
}

Future<Map<String, dynamic>> getProductJson(String name) async {
  var response = await http.get(Uri.parse("$base/myhealthboxapi/search/$name"));
  return json.decode(response.body);
}

Future<void> deleteMedIdx(String username, int index) async {
  await http.get(Uri.parse("$base/api/meds/del/$username/$index"));

  return;
}

Future<void> undoMedIdx(String username) async {
  await http.get(Uri.parse("$base/api/meds/undo/$username"));
  return;
}
