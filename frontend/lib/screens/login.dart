import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medicab/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var formKey = GlobalKey<FormState>();

  String username = "user123";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Positioned(
              left: -250,
              bottom: 20,
              height: 700,
              width: 900,
              child: Image.asset("assets/images/undraw.png")),
          Positioned(
            left: 30,
            top: 20,
            child: Image.asset("assets/images/logo_pill.png"),
          ),
          Positioned(
              bottom: 150,
              right: 40,
              child: Form(
                key: formKey,
                child: Column(children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      onSaved: (value) {},
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "Enter a Username";
                        } else {
                          setState(() {
                            username = v;
                          });
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Username",
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
                  Row(children: [
                    const Text("Let's Hop In"),
                    IconButton(
                        onPressed: () async {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('username', username);

                            if (!mounted) return;
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Home(camera: widget.camera)));
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios))
                  ])
                ]),
              )),
        ],
      ),
    ));
  }
}
