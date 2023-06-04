import 'dart:io';

import 'package:setup/setup.dart';

Future<void> main() async {
  // await setVimInBashrc.apply();
  // await installTmux.apply();
  // await installGit.apply();
  // await gitConfig.apply();
  // await ohMyTmux.apply();

  await installZsh.apply();
  await ohMyZsh.apply();
  await powerLevel10k.apply();
  await downloadP10kConfig.apply();
  await downloadZshrc.apply();
  await setVimInZshrc.apply();
  await setZshAsDefault.apply();
}

String get home => Platform.environment['HOME']!;

const String kDotfileRootUrl =
    'https://raw.githubusercontent.com/liyuqian/setup/main/dotfiles';

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

final setVimInZshrc = ConfigFileSetup(
  'zshrc editor',
  filepath: '$home/.zshrc',
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

// final setThemePowerLevel10k = SetupByCmds(
//   'Set theme powerlevel10k',
//   commands: [
//     Cmd('cp $home/.zshrc $home/.zshrc.bak'),
//     Cmd.args([
//       'sed',
//       '-i',
//       's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\\/powerlevel10k"/g',
//       '$home/.zshrc',
//     ]),
//   ],
//   check: ConfigFileCheck(
//     '$home/.zshrc',
//     ['ZSH_THEME="powerlevel10k/powerlevel10k"'],
//   ),
// );

final downloadP10kConfig = DownloadFile(
  'download p10k config',
  path: '$home/.p10k.zsh',
  url: '$kDotfileRootUrl/.p10k.zsh',
  sha512Prefix: '7a066a31',
);

final downloadZshrc = DownloadFile(
  'download zshrc',
  path: '$home/.zshrc',
  url: '$kDotfileRootUrl/.zshrc',
  sha512Prefix: '0ea69467',
);

final setZshAsDefault = SetupByCmds(
  'set zsh as default',
  commands: [Cmd('chsh -s /usr/bin/zsh')],
  check: CheckByCmd(
      Cmd('cat /etc/passwd'), (stdout) => stdout.contains('/usr/bin/zsh')),
);
