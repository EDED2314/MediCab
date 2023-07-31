import 'dart:convert';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:medicab/api/backend.dart';
import 'package:medicab/api/medi.dart';
import 'package:medicab/screens/camera.dart';
import 'package:medicab/screens/medicineinfo.dart';
import 'package:medicab/secret.dart';
import 'package:medicab/widgets/navbar.dart';

class Home extends StatefulWidget {
  Home({
    super.key,
    required this.camera,
  });

  final openAI = OpenAI.instance.build(
      token: openAIkey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  final CameraDescription camera;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, Color> locationToColor = {};
  Map<Color, String> colorToName = {};
  List<String> locations = [];
  final int shift = 1;
  bool disabled = false;
  List<Medicine> medicines = [];
  List<Map<String, String>> userMedicines = [];

  late Medicine deletedMed;
  late int deletedIdx;

  Future<String> chatComplete(String prompt) async {
    final request = ChatCompleteText(
        messages: [Messages(role: Role.user, content: prompt)],
        maxToken: 500,
        model: GptTurbo0301ChatModel());

    final response = await widget.openAI.onChatCompletion(request: request);
    // for (var element in response!.choices) {
    //   print("data -> ${element.message?.content}");
    // }
    return response?.choices[0].message?.content ?? "ERROR";
  }

  List<Color> colors = [
    const Color.fromARGB(255, 94, 175, 241),
    const Color.fromARGB(255, 97, 206, 101),
    const Color.fromARGB(255, 213, 202, 99),
    const Color.fromARGB(255, 162, 22, 187),
    Colors.orange,
  ];

  List<String> colorsNames = [
    "🔵 Blue",
    "🟢 Green",
    "🟡 Yellow",
    "🟣 Purple",
    "🟠 Orange",
  ];

  List<Widget> generateColorKey() {
    List<Widget> ret = [
      const Text("Colors-to-Location Key"),
    ];
    Map<Color, bool> usedColorOrNot = {};
    for (int i = 0; i < locations.length; i++) {
      if (!usedColorOrNot.containsKey(locationToColor[locations[i]])) {
        ret.add(Text(
            "${colorToName[locationToColor[locations[i]]]}: ${locations[i]}"));
        usedColorOrNot[locationToColor[locations[i]] ?? Colors.blue] = true;
      }
    }
    return ret;
  }

  void generateColorToStringMap() {
    for (int i = 0; i < colors.length; i++) {
      colorToName[colors[i]] = colorsNames[i];
    }
    setState(() {});
  }

  void generateColorMap() {
    int currentColorIndex = 0;
    for (int i = 0; i < locations.length; i++) {
      if (!locationToColor.containsKey(locations[i])) {
        locationToColor[locations[i]] = colors[currentColorIndex];
        currentColorIndex++;
      }
    }
    setState(() {});
  }

  String imageFromMediType(String type) {
    if (type == "pill") {
      return "assets/images/drug2.png";
    } else if (type == "liquid") {
      return "assets/images/drug3.png";
    }
    return "assets/images/pill.png";
  }

  void generateMedicineObjectList() {
    for (Map<String, String> med in userMedicines) {
      medicines.add(Medicine.fromJson(med));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    refresh();
  }

  Future<void> refresh() async {
    String username = await readUsername();
    List<Map<String, String>> meds = await getMeds(username);
    // print(meds);
    setState(() {
      medicines = [];
      locations = [];
    });
    userMedicines = meds;
    generateMedicineObjectList();

    for (Medicine med in medicines) {
      String location = med.location;
      locations.add(location);
    }

    // we need the locations list to generate succesfully.
    generateColorMap();
    generateColorToStringMap();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.refresh),
        //   onPressed: () async {
        //     await refresh();
        //   },
        // ),
        title: const Text("Your Cabinet 🗄️"),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
              padding: const EdgeInsets.all(1),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            TakePictureScreen(camera: widget.camera)));
                  },
                  icon: const Icon(Icons.camera_alt_rounded)))
        ],
        shadowColor: Colors.grey,
        elevation: 2,
      ),
      bottomNavigationBar: const Navbar(selectedIndex: 1),
      body: SafeArea(
          child: Stack(children: [
        Center(
            child: Padding(
          padding: const EdgeInsets.all(19),
          child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              // shrinkWrap: true,
              itemCount: medicines.length + shift,
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  return Card(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: generateColorKey()))),
                  );
                }

                String name = medicines[idx - shift].name;
                String subtitle = medicines[idx - shift].shortDescription;
                String location = medicines[idx - shift].location;
                String expirationTime = medicines[idx - shift].expirationTime;
                String dosagePerDay = medicines[idx - shift].dosagePerDay;

                return Dismissible(
                    background: Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(25))),
                    key: ValueKey(medicines[idx - shift]),
                    onDismissed: (DismissDirection direction) async {
                      setState(() {
                        deletedIdx = idx - shift;
                        deletedMed = medicines[idx - shift];
                        medicines.removeAt(idx - shift);
                      });

                      String username = await readUsername();
                      await deleteMedIdx(username, deletedIdx);

                      SnackBar snackbar = SnackBar(
                        content: Text("Successfully Deleted Medicine $name"),
                        action: SnackBarAction(
                          label: "Undo?",
                          onPressed: () async {
                            setState(() {
                              medicines.insert(deletedIdx, deletedMed);
                            });
                            await undoMedIdx(username);
                          },
                        ),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);

                      await refresh();
                    },
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )),
                      leading: SizedBox(
                        height: 40,
                        width: 40,
                        child: Image.asset(
                            imageFromMediType(medicines[idx - shift].type)),
                      ),
                      title: Text(
                        name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      tileColor: locationToColor[location],
                      subtitle: Text(subtitle),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Expries at:"),
                          Text(expirationTime),
                          const Text("Intake amount:"),
                          Text(dosagePerDay),
                        ],
                      ),
                      onTap: () async {
                        // api stuff getting the correct thing based on the name.
                        if (disabled) return;
                        setState(() {
                          disabled = true;
                        });
                        //deatiled medicine is gonna be from the api..
                        Map<String, dynamic> productJson =
                            await getProductJson(name);

                        String jsondata = json.encode(productJson);

                        String resp = await chatComplete(
                            "describe $name for me using what you know and this json data\n\ndo not add any warnings or 'please notes'\n\n$jsondata");

                        if (!mounted) return;
                        showDialog(
                            context: context,
                            builder: (context) {
                              return MediInfo(
                                name: name,
                                body: resp,
                              );
                            });
                        setState(() {
                          disabled = false;
                        });
                      },
                    ));
              },
              separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  )),
        )),
        disabled
            ? Center(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200.withOpacity(0.5)),
                        child: const Center(
                            child: SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(
                                  strokeWidth: 10,
                                )))),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ])),
    );
  }
}
