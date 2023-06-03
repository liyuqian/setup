import 'dart:io';

import 'package:setup/setup.dart';

String get home => Platform.environment['HOME']!;

final setVimInBashrc = ConfigFileSetup(
  'bashrc editor',
  filepath: '$home/.bashrc',
  lines: [
    'export VISUAL=vim',
    'export EDITOR="\$VISUAL"',
  ],
);

final installTmux = SetupByCmds(
  'install tmux',
  commands: [Cmd('sudo apt install tmux')],
  check: CheckByCmd(
    Cmd('tmux -V'),
    (stdout) => stdout.contains('tmux 3'),
  ),
);

final installGit = SetupByCmds(
  'install git',
  commands: [Cmd('sudo apt install git')],
  check: CheckByCmd(
    Cmd('git --version'),
    (stdout) => stdout.contains('git version'),
  ),
);

final gitConfig = SetupByCmds(
  'config git',
  commands: [
    Cmd.args(['git', 'config', '--global', 'user.name', 'Yuqian Li']),
    Cmd('git config --global user.email "liyuqian79@gmail.com"'),
  ],
  check: CheckByCmd(
    Cmd('git config --global user.name'),
    (stdout) => stdout.contains('Yuqian Li'),
  ),
);

final ohMyTmux = SetupByCmds(
  'install oh-my-tmux',
  commands: Cmd.simpleLines([
    'git clone https://github.com/gpakosz/.tmux.git',
    'ln -s -f .tmux/.tmux.conf',
    'cp .tmux/.tmux.conf.local .',
  ], path: home),
  check: FileCheck('$home/.tmux.conf'),
);

Future<void> main() async {
  await setVimInBashrc.apply();
  await installTmux.apply();
  await installGit.apply();
  await gitConfig.apply();
  await ohMyTmux.apply();
}
