import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medicab/screens/chat/chat_screen.dart';
import 'package:medicab/screens/home.dart';
import 'package:medicab/screens/profile.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;
  // ignore: use_key_in_widget_constructors
  const Navbar({Key? key, required this.selectedIndex});

  @override
  State<StatefulWidget> createState() => NavBarState();
}

class NavBarState extends State<Navbar> {
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.selectedIndex;
    });
  }

  void _onItemTapped(int index) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    if (!mounted) return;
    if (index == 1) {
      setState(() {
        _selectedIndex = index;
      });

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Home(
                camera: firstCamera,
              )));
    } else if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const ProfilePage()));
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const ChatScreen()));
    }

    // if selectedIndex == indexof a page
    // nav push
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'AI Chat',
        ),
      ],
      currentIndex: _selectedIndex,
      // backgroundColor: _isbday ? Colors.amber[700] : null,
      // selectedItemColor: _isbday ? Colors.white : primaryColorColor,
      onTap: _onItemTapped,
    );
  }
}
