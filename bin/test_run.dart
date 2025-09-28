import 'package:setup/collection.dart';

Future<void> main() async {
  await SnapInstall('google-cloud-cli', extraArg: '--classic').apply();
}
