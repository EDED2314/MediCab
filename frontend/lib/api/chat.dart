import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:medicab/secret.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat {
  static Map<String, Role> roleNametoObject = {
    "user": Role.user,
    "assistant": Role.assistant,
    "system": Role.system
  };

  List<Messages> chatHistory = [];
  final openAI = OpenAI.instance.build(
      token: openAIkey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  Future<String> sendMessage(String message) async {
    chatHistory.add(Messages(role: Role.user, content: message));
    String botResponse = await chatComplete(message);
    chatHistory.add(Messages(role: Role.assistant, content: botResponse));
    return botResponse;
  }

  Future<String> chatComplete(String prompt) async {
    final request = ChatCompleteText(
        messages: chatHistory, maxToken: 500, model: GptTurbo0301ChatModel());
    final response = await openAI.onChatCompletion(request: request);
    return response?.choices[0].message?.content ?? "ERROR";
  }

  Future<void> exportToShared() async {
    List<String> export = [];
    for (Messages msg in chatHistory) {
      String content = msg.content ?? "";
      String role = msg.role.name;
      String msgMapEncoded = json.encode({"content": content, "role": role});
      export.add(msgMapEncoded);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('chat', export);
  }

  List<Map<String, String>> exportToListMap() {
    List<Map<String, String>> export = [];
    for (Messages msg in chatHistory) {
      String content = msg.content ?? "";
      String role = msg.role.name;
      Map<String, String> msgMap = {"content": content, "role": role};
      export.add(msgMap);
    }
    return export;
  }

  static Future<Chat> importFromShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('chat') ?? [];
    List<Messages> his = [];
    for (String msg in history) {
      Map<String, dynamic> msgMap = json.decode(msg);
      Role role = roleNametoObject[msgMap["role"] ?? "user"] ?? Role.user;
      String content = msgMap["content"] ?? "";
      his.add(Messages(role: role, content: content));
    }

    Chat chat = Chat();
    chat.chatHistory = his;
    return chat;
  }
}
