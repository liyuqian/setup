import 'dart:io';

import 'package:logger/logger.dart';

import 'setup.dart';

Future<void> setUpZsh({Logger? logger}) async {
  final setups = [
    installZsh,
    cloneFzf,
    installFzf,
    ohMyZsh,
    powerLevel10k,
    installAutojump,
    getZshAutosuggestions,
    getZshSyntaxHighlighting,
    setVimInZshrc,
    setZshAsDefault,
  ];
  for (final setup in setups) {
    await setup.apply(logger: logger);
  }
}

final installZsh = AptInstall('zsh');
final installAutojump = AptInstall('autojump');
final getZshAutosuggestions = GetOmzPlugin('zsh-autosuggestions');
final getZshSyntaxHighlighting = GetOmzPlugin('zsh-syntax-highlighting');

final cloneFzf = SetupByCmds('clone fzf',
    commands: [
      Cmd('git clone --depth 1 https://github.com/junegunn/fzf.git $home/.fzf')
    ],
    check: FileCheck('$home/.fzf'));

final installFzf = SetupByCmds('install fzf',
    commands: [
      Cmd('$home/.fzf/install --key-bindings --completion --no-update-rc')
    ],
    check: FileCheck('$home/.fzf.zsh'));

final ohMyZsh = SetupByCmds(
  'install oh-my-zsh',
  commands: [
    Cmd.args([
      'curl',
      '-fsSL',
      '$kRawGithubRoot/ohmyzsh/ohmyzsh/master/tools/install.sh',
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

final setZshAsDefault = SetupByCmds(
  'set zsh as default',
  commands: [Cmd('sudo chsh -s /usr/bin/zsh ${Platform.environment['USER']}')],
  check: CheckByCmd(
      Cmd('cat /etc/passwd'), (stdout) => stdout.contains('/usr/bin/zsh')),
);

final setVimInZshrc = ConfigFileSetup(
  'zshrc editor',
  filepath: '$home/.zshrc',
  lines: [
    'export VISUAL=vim',
    'export EDITOR="\$VISUAL"',
  ],
);
