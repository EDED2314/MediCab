import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medicab/api/backend.dart';
import 'package:medicab/screens/home.dart';
import 'package:medicab/secret.dart';
//import 'package:shared_preferences/shared_preferences.dart';

extension VirtualKeyboard on BuildContext {
  /// is dark mode currently enabled?
  bool get virtualKeyboardIsOpen {
    return MediaQuery.of(this).viewInsets.bottom > 0;
  }
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  bool isTakingPhotoAndSendingImage = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.

            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          setState(() {
            isTakingPhotoAndSendingImage = true;
            _controller.pausePreview();
          });
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            String username = await readUsername();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            List<String> data =
                await sendImageAndGetMedicine(username, image.path);
            // if (kDebugMode) {
            //   print(data);
            // }

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    Home(camera: widget.camera),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    DisplayPictureScreen(
                  imagePath: image.path,
                  data: data,
                  camera: widget.camera,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: isTakingPhotoAndSendingImage
            ? const CircularProgressIndicator()
            : const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final List<String> data;
  final CameraDescription camera;

  const DisplayPictureScreen(
      {super.key,
      required this.imagePath,
      required this.data,
      required this.camera});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Future<String> chatComplete(String prompt) async {
    final request = ChatCompleteText(
        messages: [Messages(role: Role.user, content: prompt)],
        maxToken: 500,
        model: GptTurbo0301ChatModel());

    final openAI = OpenAI.instance.build(
        token: openAIkey,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
        enableLog: true);
    final response = await openAI.onChatCompletion(request: request);
    // for (var element in response!.choices) {
    //   print("data -> ${element.message?.content}");
    // }
    return response?.choices[0].message?.content ?? "ERROR";
  }

  String generateNameList(List<String> data) {
    String ret = "";
    for (String daa in data) {
      ret += "\n$daa";
    }
    return ret;
  }

  bool loading = false;
  var formKey = GlobalKey<FormState>();

  String store = "";

  @override
  Widget build(BuildContext context) {
    bool notFound = (widget.data.isEmpty);

    return Scaffold(
        appBar: AppBar(title: const Text('Here\'s what we got.')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
              child: Column(children: [
            context.virtualKeyboardIsOpen
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 350, child: Image.file(File(widget.imagePath))),
            notFound
                ? const Text("Nothing found :<")
                : Text(
                    "We found that you have...${generateNameList(widget.data)}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 27),
                  ),
            const SizedBox(
              height: 20,
            ),
            notFound
                ? const SizedBox.shrink()
                : Form(
                    key: formKey,
                    child: Column(children: [
                      SizedBox(
                        width: 500,
                        child: TextFormField(
                          onSaved: (value) {},
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Enter a Location";
                            } else {
                              setState(() {
                                store = v;
                              });
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            hintText:
                                "Enter where you are storing the medicine.",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            String username = await readUsername();
                            formKey.currentState!.save();
                            if (formKey.currentState!.validate()) {
                              //submit form and do stuff.
                              // like get gpt response and stuff..
                              //store
                              String location = store;
                              List<Map<String, String>> payload = [];
                              Random random = Random();
                              for (String med in widget.data) {
                                String shortdesc = await chatComplete(
                                    "generate a very very very short description of the medicine $med without its name");
                                String logdesc = await chatComplete(
                                    "generate a short descipriton of the medicine $med ");

                                int randomDay = random.nextInt(24) + 1;
                                int randomMonth = random.nextInt(11) + 1;
                                int randomYear = random.nextInt(3) + 2024;

                                String expTime =
                                    "$randomMonth-$randomDay-$randomYear";

                                int dose = random.nextInt(2) + 1;
                                String dosss = "$dose pill/day";

                                List<String> types = ["pill", "liquid"];
                                int randomtypeIndex =
                                    random.nextInt(types.length);
                                String type = types[randomtypeIndex];

                                payload.add({
                                  "name": med,
                                  "short_description": shortdesc,
                                  "long_description": logdesc,
                                  "location": location,
                                  "expiration_time": expTime,
                                  "dosage_per_day": dosss,
                                  "type": type
                                });
                              }

                              //after for loop send payload to save_meds with username
                              await updateMedList(username, payload);

                              if (!mounted) return;

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Home(camera: widget.camera)));
                            }
                          },
                          child: SizedBox(
                              height: 50,
                              width: 120,
                              child: Center(
                                  child: loading
                                      ? const Text(
                                          "Loading...",
                                          style: TextStyle(fontSize: 20),
                                        )
                                      : const Text(
                                          "Done",
                                          style: TextStyle(fontSize: 20),
                                        )))),
                    ]),
                  )
          ])),
        ));
  }
}
