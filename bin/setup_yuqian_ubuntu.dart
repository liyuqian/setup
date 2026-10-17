import 'package:setup/collection.dart';

Future<void> main() async {
  await setupUbuntu();
  await makeGitSetup("Yuqian Li", "liyuqian79@gmail.com").apply();
}
