import 'dart:io';

import 'setup.dart';

SetupByCmds makeGitSetup(String name, String email) {
  return SetupByCmds(
    'config git',
    commands: [
      Cmd.args(['git', 'config', '--global', 'user.name', name]),
      Cmd('git config --global user.email "$email"'),
    ],
    check: CheckByCmd(
      Cmd('git config --global user.name'),
      (stdout) => stdout.contains(name),
      okExitCodes: [0, 1],
    ),
  );
}

final ohMyTmux = SetupByCmds('install oh-my-tmux',
    commands: Cmd.simpleLines([
      'git clone https://github.com/gpakosz/.tmux.git',
      'ln -s -f .tmux/.tmux.conf',
      'cp .tmux/.tmux.conf.local .',
    ], path: home),
    check: FileCheck('$home/.tmux.conf'));

final ultimateVimrc = SetupByCmds(
  'ultimate vimrc',
  commands: [
    Cmd.args([
      'git',
      'clone',
      '--depth=1',
      'https://github.com/amix/vimrc.git',
      '$home/.vim_runtime',
    ]),
  ],
  check: FileCheck('$home/.vim_runtime'),
);

class VimPlugin extends SetupByCmds {
  VimPlugin(String url, {String? branch})
      : super(
          parseName(url),
          commands: [
            Cmd('mkdir -p $path'),
            Cmd.args(
              ['git', 'clone', '--depth=1'] +
                  (branch != null ? ['-b', branch] : []) +
                  [url, '$path/${parseName(url)}'],
            ),
          ],
          check: FileCheck('$path/${parseName(url)}'),
        );

  static String get path => '$home/.vim/pack/plugins/start';
  static String parseName(String url) => Uri.parse(url).pathSegments.last;
}

final dartVimPlugin = VimPlugin('https://github.com/dart-lang/dart-vim-plugin');
final ctrlpVimPlugin = VimPlugin('https://github.com/kien/ctrlp.vim.git');
final fzfPlugin = VimPlugin('https://github.com/junegunn/fzf');
final fzfVimPlugin = VimPlugin('https://github.com/junegunn/fzf.vim');
final cocVimPlugin =
    VimPlugin('https://github.com/neoclide/coc.nvim', branch: 'release');

Future<void> setUpPdm() async {
  if (Platform.isLinux) {
    await setUpMultiple([_installPdmOnLinux, _setupPdmPathOnLinux]);
  } else if (Platform.isMacOS) {
    await BrewInstall('pdm').apply();
  }
}

final _installPdmOnLinux = SetupByCmds(
  'install pdm',
  commands: Cmd.simpleLines([
    'curl -sSL https://pdm-project.org/install-pdm.py -o /tmp/install-pdm.py',
    'python3 /tmp/install-pdm.py',
  ]),
  check: FileCheck('$home/.local/bin/pdm'),
);
final _setupPdmPathOnLinux = ConfigFileSetup(
  'add pdm to \$PATH',
  filepath: rcFilePath,
  lines: ['export PATH=$home/.local/bin:\$PATH'],
);

final protocPluginSetup = SetupByCmds('install protoc_plugin',
    commands: Cmd.simpleLines([
      'dart pub global activate protoc_plugin',
    ]),
    check: CheckByCmd(
      Cmd('dart pub global list'),
      (stdout) => stdout.contains('protoc_plugin'),
    ));

final installBun = SetupByCmds('install bun',
    commands: Cmd.simpleLines([
      'curl -fsSL https://bun.sh/install -o /tmp/install-bun.sh',
      'bash /tmp/install-bun.sh',
    ]),
    check: FileCheck('$home/.bun/bin/bun'));

final installFirebase = SetupByCmds('install firebase cli',
    commands: Cmd.simpleLines([
      'curl -sL https://firebase.tools -o /tmp/install-firebase.sh',
      'bash /tmp/install-firebase.sh'
    ]),
    check: CheckCmdExistence('firebase --version'));
