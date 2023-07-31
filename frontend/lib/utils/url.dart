// ignore: non_constant_identifier_names
import 'package:url_launcher/url_launcher.dart';

Future<void> launchAUrl(String urll) async {
  final Uri url = Uri.parse(urll);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
