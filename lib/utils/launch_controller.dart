import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url) async {
  final link = Uri.parse(url);
  if (await canLaunchUrl(link)) {
    launchUrl(link, mode: LaunchMode.externalApplication);
  } else {
    throw 'Can not launch';
  }
}
