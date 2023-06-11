import 'package:setup/setup.dart';

Future<void> main() async {
  await setUpPython();
}

Future<void> setUpPython() async {
  await installPip.apply();
  await installPoetry.apply();
  await configPoetryVenv.apply();
}

final installPip = AptInstall('python3-pip');

final installPoetry = SetupByCmds('install poetry',
    commands: Cmd.simpleLines([
      'python3 -m pip install poetry',
    ]),
    check: CheckByCmd(
      Cmd('python3 -m poetry --version'),
      (stdout) => stdout.contains('Poetry (version'),
      okExitCodes: [0, 1],
    ));

final configPoetryVenv = SetupByCmds(
  'config poetry venv',
  commands: [Cmd('python3 -m poetry config virtualenvs.in-project true')],
  check: CheckByCmd(Cmd('python3 -m poetry config virtualenvs.in-project'),
      (stdout) => stdout.contains('true')),
);
