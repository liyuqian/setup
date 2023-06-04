import 'dart:io';

import 'package:setup/setup.dart';

String get home => Platform.environment['HOME']!;

final installTmux = AptInstall('tmux');
final installGit = AptInstall('git');
final installZsh = AptInstall('zsh');

final setVimInBashrc = ConfigFileSetup(
  'bashrc editor',
  filepath: '$home/.bashrc',
  lines: [
    'export VISUAL=vim',
    'export EDITOR="\$VISUAL"',
  ],
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

final ohMyTmux = SetupByCmds('install oh-my-tmux',
    commands: Cmd.simpleLines([
      'git clone https://github.com/gpakosz/.tmux.git',
      'ln -s -f .tmux/.tmux.conf',
      'cp .tmux/.tmux.conf.local .',
    ], path: home),
    check: FileCheck('$home/.tmux.conf'));

final ohMyZsh = SetupByCmds(
  'install oh-my-zsh',
  commands: [
    Cmd.args([
      'curl',
      '-fsSL',
      'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh',
      '-o',
      '/tmp/install_oh_my_zsh.sh',
    ]),
    Cmd('sh /tmp/install_oh_my_zsh.sh'),
  ],
  check: FileCheck('$home/.oh-my-zsh/README.md'),
);

final powerLevel10k = SetupByCmds(
  'install powerlevel10k',
  commands: [
    Cmd.args([
      'git',
      'clone',
      '--depth=1',
      'https://github.com/romkatv/powerlevel10k.git',
      '$home/.oh-my-zsh/custom/themes/powerlevel10k',
    ]),
  ],
  check: FileCheck('$home/.oh-my-zsh/custom/themes/powerlevel10k/README.md'),
);

final setThemePowerLevel10k = SetupByCmds(
  'Set theme powerlevel10k',
  commands: [
    Cmd('cp $home/.zshrc $home/.zshrc.bak'),
    Cmd.args([
      'sed',
      '-i',
      's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\\/powerlevel10k"/g',
      '$home/.zshrc',
    ]),
  ],
  check: ConfigFileCheck(
    '$home/.zshrc',
    ['ZSH_THEME="powerlevel10k/powerlevel10k"'],
  ),
);

Future<void> main() async {
  // await setVimInBashrc.apply();
  // await installTmux.apply();
  // await installGit.apply();
  // await installZsh.apply();
  // await gitConfig.apply();
  // await ohMyTmux.apply();

  await ohMyZsh.apply();
  await powerLevel10k.apply();
  await setThemePowerLevel10k.apply();
}
