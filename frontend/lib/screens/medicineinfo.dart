import 'package:flutter/material.dart';

class MediInfo extends StatefulWidget {
  const MediInfo({super.key, required this.name, required this.body});
  final String name;
  final String body;

  @override
  State<MediInfo> createState() => _MediInfoState();
}

class _MediInfoState extends State<MediInfo> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(
          "More Information about ${widget.name}",
        ),
        content: SingleChildScrollView(child: Text(widget.body)));
  }
}
