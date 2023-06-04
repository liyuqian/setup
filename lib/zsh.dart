import 'dart:io';

import 'package:logger/logger.dart';

import 'setup.dart';

Future<void> setUpZsh(String dotfileRootUrl, {Logger? logger}) async {
  final setups = [
    installFzf,
    installZsh,
    ohMyZsh,
    powerLevel10k,
    makeDownloadP10kConfig(dotfileRootUrl),
    installAutojump,
    getZshAutosuggestions,
    getZshSyntaxHighlighting,
    makeDownloadZshrc(dotfileRootUrl),
    setVimInZshrc,
    setZshAsDefault,
  ];
  for (final setup in setups) {
    await setup.apply(logger: logger);
  }
}

final installFzf = AptInstall('fzf');
final installZsh = AptInstall('zsh');
final installAutojump = AptInstall('autojump');
final getZshAutosuggestions = GetOmzPlugin('zsh-autosuggestions');
final getZshSyntaxHighlighting = GetOmzPlugin('zsh-syntax-highlighting');

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

Setup makeDownloadP10kConfig(String dotfileRootUrl) => DownloadFile(
      'download p10k config',
      path: '$home/.p10k.zsh',
      url: '$dotfileRootUrl/.p10k.zsh',
      sha512Prefix: '7a066a31',
    );

Setup makeDownloadZshrc(String dotfileRootUrl) => DownloadFile(
      'download zshrc',
      path: '$home/.zshrc',
      url: '$dotfileRootUrl/.zshrc',
      sha512Prefix: '313b846e',
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
