import 'package:flutter/material.dart';
//import 'package:medicab/api/backend.dart';
import 'package:medicab/api/fakedata.dart';
import 'package:medicab/api/user.dart';
import 'package:medicab/utils/base64_to_image.dart';
import 'package:medicab/utils/url.dart';
import 'package:medicab/widgets/navbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user = eddie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile 🩺"),
        automaticallyImplyLeading: false,
        shadowColor: Colors.grey,
        elevation: 2,
        // leading: IconButton(
        //   icon: const Icon(Icons.refresh),
        //   onPressed: () async {
        //     // String username = await readUsername();
        //     // User s = await getUser(username);
        //     // setState(() {
        //     //   user = s;
        //     // });
        //   },
        // ),
      ),
      body: SafeArea(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(
                              child: CircleAvatar(
                                backgroundImage:
                                    imageFromBase64String(eddie.pfp).image,
                                radius: 50.0,
                              ),
                            ),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ListTile(
                              title: const Text("Age"),
                              trailing: Text(
                                user.age,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            ListTile(
                              title: const Text("Gender"),
                              trailing: Text(
                                user.gender,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            ListTile(
                              title: const Text("Medicines in Cabinet"),
                              trailing: Text(
                                "${userMedicines.length}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      )),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ListTile(
                              leading: SizedBox(
                                height: 20,
                                width: 20,
                                child: Image.asset("assets/images/drug1.png"),
                              ),
                              title: const Text("Resource 1"),
                              trailing: const Text("Tap Me"),
                              onTap: () async {
                                await launchAUrl(
                                    "https://www.samhsa.gov/find-help/national-helpline");
                              },
                            ),
                            ListTile(
                              leading: SizedBox(
                                height: 20,
                                width: 20,
                                child: Image.asset("assets/images/drug2.png"),
                              ),
                              title: const Text("Resource 2"),
                              trailing: const Text("Tap Me"),
                              onTap: () async {
                                await launchAUrl(
                                    "https://www.dea.gov/recovery-resources");
                              },
                            ),
                            ListTile(
                              leading: SizedBox(
                                height: 20,
                                width: 20,
                                child: Image.asset("assets/images/drug3.png"),
                              ),
                              title: const Text("Resource 3"),
                              trailing: const Text("Tap Me"),
                              onTap: () async {
                                await launchAUrl(
                                    "https://nj.gov/humanservices/dmhas/home/hotlines/");
                              },
                            ),
                          ],
                        ),
                      ))
                    ],
                  )))),
      bottomNavigationBar: const Navbar(selectedIndex: 0),
    );
  }
}
