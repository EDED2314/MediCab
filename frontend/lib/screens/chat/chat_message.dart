import 'package:flutter/material.dart';
import 'package:medicab/api/fakedata.dart';
import 'package:medicab/utils/base64_to_image.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {super.key,
      required this.text,
      required this.sender,
      this.isImage = false});

  final String text;
  final String sender;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    List<Widget> body = [
      sender == "You"
          ? Center(
              child: CircleAvatar(
                backgroundImage: imageFromBase64String(eddie.pfp).image,
                radius: 25,
              ),
            )
          : const Center(
              child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://cdn-icons-png.flaticon.com/512/5988/5988000.png"),
              radius: 25,
            )),
      // Text(sender)
      //     .text
      //     .subtitle1(context)
      //     .make()
      //     .box
      //     .color(sender == "You" ? Vx.red200 : Vx.green200)
      //     .p16
      //     .rounded
      //     .alignCenter
      //     .makeCentered(),
      Expanded(
          child: isImage
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    text,
                    loadingBuilder: (context, child, loadingProgress) =>
                        loadingProgress == null
                            ? child
                            : const CircularProgressIndicator.adaptive(),
                  ),
                )
              : sender == "You"
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          text.trim(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          text.trim(),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    )
          // : Text(
          //     text.trim(),
          //     textAlign: TextAlign.right,
          //   ).text.bodyText1(context).make().px8(),
          ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sender == "You" ? body : body.reversed.toList(),
    ).py8();
  }
}
