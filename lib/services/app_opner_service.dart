import 'package:url_launcher/url_launcher.dart';
import 'package:sermon/services/firebase/firebase_remote_config.dart';

class AppOpener {
  // Launches a URL
  static Future<void> launchAppUsingUrl({required String link}) async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  // Launches a URL
  static Future<void> launchPrivacyPolicy() async {
    final privacyPolicyUrl = FirebaseRemoteConfigService().privacyPolicyUrl;
    final Uri url = Uri.parse(privacyPolicyUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  static Future<void> launchWhatsappChatSupport() async {
    final whatsappNumber = FirebaseRemoteConfigService().whatsappSupportNumber;
    await AppOpener.launchAppUsingUrl(
      link:
          'https://wa.me/$whatsappNumber?text=Hey,%20I%20downloaded%20direction%20-%20I%20am%20having%20a%20problem',
    );
  }
}
