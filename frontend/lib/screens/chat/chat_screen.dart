import 'dart:async';
import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:medicab/api/backend.dart';
import 'package:medicab/api/chat.dart';
import 'package:medicab/api/diag.dart';
import 'package:medicab/secret.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:medicab/api/chat.dart';

import 'package:medicab/screens/chat/chat_message.dart';
import 'threedots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Map<String, String> usernameMap = {"user": "You", "assistant": "Cabinet-AI"};

  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  Chat chat = Chat();
  DiagnosisSession dia = DiagnosisSession();

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void convertChatToMessages() {
    List<Map<String, String>> mps = chat.exportToListMap();
    // "content"
    //"role"
    List<ChatMessage> msgs = [];
    for (Map<String, String> mp in mps.reversed.toList()) {
      String content = mp["content"] ?? "";
      String role = mp["role"] ?? "system";
      if (role != "system") {
        ChatMessage msg =
            ChatMessage(text: content, sender: usernameMap[role] ?? "error");
        msgs.add(msg);
      }
    }

    setState(() {
      _messages = msgs;
    });
  }

  void init() async {
    Chat achat = await Chat.importFromShared();
    setState(() {
      chat = achat;
    });
    convertChatToMessages();
  }

  void addMsg(String msg, String sender, bool typing) {
    ChatMessage message = ChatMessage(
      text: msg,
      sender: sender,
    );

    if (sender == "You") {
      chat.chatHistory.add(Messages(role: Role.user, content: msg));
    } else {
      chat.chatHistory.add(Messages(role: Role.assistant, content: msg));
    }

    setState(() {
      _messages.insert(0, message);
      _isTyping = typing;
    });
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    if (_controller.text.toLowerCase().contains("dia me") || dia.inSession) {
      // if (_controller.text.toLowerCase().contains("dia")) {
      //   String username = await readUsername();
      //   List<Map<String, String>> meds = await getMeds(username);
      //   String encoded = json.encode(meds);
      //   //   chat.chatHistory.add(Messages(
      //   //       role: Role.system,
      //   //       content:
      //   //           "The User has these medicines in their cabinet (stored in a json format), please take note as you diagnose the user, and RECOMMEND if possible ONE OF THE MEDCINES the USER CAN TAKE UNDER DOCTOR GUIDANCE:\n$encoded"));
      //   // }}
      // }
      dia.inSession = true;
      String username = await readUsername();
      String msg = _controller.text;

      addMsg(_controller.text, "You", true);
      _controller.clear();

      String response = await dia.postAndRecieveNextQuestion(msg, username);

      addMsg(response, "Cabinet-AI", false);

      if (response.contains("how many days")) {
        dia.inSession = false;
      }

      return;
    } else {
      addMsg(_controller.text, "You", true);

      _controller.clear();

      final openAI = OpenAI.instance.build(
          token: openAIkey,
          baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
          enableLog: true);

      final request = ChatCompleteText(
          messages: chat.chatHistory,
          maxToken: 500,
          model: GptTurbo0301ChatModel());
      final response = await openAI.onChatCompletion(request: request);

      String resp = response?.choices[0].message?.content ?? "ERROR";

      addMsg(resp, "Cabinet-AI", false);
    }
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) async {
              _sendMessage();
            },
            decoration:
                const InputDecoration.collapsed(hintText: "Enter message here"),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _sendMessage();
              },
            ),
          ],
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cabinet-AI",
          ),
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.grey,
          // automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              await chat.exportToShared();
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Chat History?"),
                          actions: [
                            ElevatedButton(
                                onPressed: () async {
                                  Chat chat = Chat();
                                  await chat.exportToShared();
                                  init();

                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Yes",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("No",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.delete))
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) const ThreeDots(),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}
