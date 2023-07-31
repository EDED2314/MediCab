import 'dart:convert';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DiagnosisSession {
  String urlBase = "http://192.168.86.111:5600";
  bool inSession = false;

  Future<String> postAndRecieveNextQuestion(
      String message, String username) async {
    var response = await http
        .get(Uri.parse("$urlBase/chatbot/sendres/$username/$message"));

    // {"bot-msg": "adsfadsf"}
    return json.decode(response.body);
  }
}
