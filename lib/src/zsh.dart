import 'dart:io';

import 'package:logger/logger.dart';

import 'setup.dart';

Future<void> setUpZshMac({Logger? logger}) async {
  await setUpZsh(preSetups: [BrewInstall('autojump')]);
}

Future<void> setUpZshUbuntu({Logger? logger}) async {
  await setUpZsh(preSetups: [
    AptInstall('zsh'),
    AptInstall('autojump'),
    setZshAsDefault,
  ]);
}

Future<void> setUpZsh({required List<Setup> preSetups, Logger? logger}) async {
  final List<Setup> setups = [
    ...preSetups,
    cloneFzf,
    installFzf,
    ohMyZsh,
    powerLevel10k,
    GetOmzPlugin('zsh-autosuggestions'),
    GetOmzPlugin('zsh-syntax-highlighting'),
    setVimInZshrc,
  ];
  for (final setup in setups) {
    await setup.apply(logger: logger);
  }
}

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
