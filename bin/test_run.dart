import 'package:setup/collection.dart';

Future<void> main() async {
  await BrewInstall('google-chrome', extraArg: '--cask').apply();
}
