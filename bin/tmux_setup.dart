import 'dart:io';

import 'package:setup/setup.dart';

final tmux = Setup(
  'Install tmux',
  commands: [Cmd('sudo apt install tmux')],
  check: Check(
    Cmd('tmux -V'),
    (stdout) => stdout.contains('tmux 3'),
  ),
);

final git = Setup(
  'Install git',
  commands: [Cmd('sudo apt install git')],
  check: Check(
    Cmd('git --version'),
    (stdout) => stdout.contains('git version'),
  ),
);

String get home => Platform.environment['HOME']!;

final ohMyTmux = Setup(
  'Install oh-my-tmux',
  commands: Cmd.simpleLines([
    'git clone https://github.com/gpakosz/.tmux.git',
    'ln -s -f .tmux/.tmux.conf',
    'cp .tmux/.tmux.conf.local .',
  ], path: home),
  check: Check(
    Cmd('cat $home/.tmux.conf | sha1sum'),
    (stdout) => stdout.startsWith('bc4d5528'),
  ),
);

Future<void> main() async {
  await Cmd('echo "hello"').run();
}
