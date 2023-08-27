import 'package:setup/dotfile.dart';
import 'package:setup/setup.dart';
import 'package:setup/zsh.dart';

Future<void> main() async {
  await setVimInBashrc.apply();
  await installGit.apply();
  await gitConfig.apply();

  await installTmux.apply();
  await ohMyTmux.apply();
  await installXclip.apply();

  await setUpZsh();

  await installNode19.apply();

  await installLatestVim.apply();
  await ultimateVimrc.apply();
  await ctrlpVimPlugin.apply();
  await dartVimPlugin.apply();
  await fzfPlugin.apply();
  await fzfVimPlugin.apply();
  await cocVimPlugin.apply();

  await downloadDotfiles(kDotfileRootUrl);
}

const String kDotfileRootUrl =
    'https://raw.githubusercontent.com/liyuqian/setup/main/dotfiles';

final installGit = AptInstall('git');
final installTmux = AptInstall('tmux');
final installXclip = AptInstall('xclip');

final installNode19 = SetupByCmds('Install nodejs 19',
    commands: Cmd.simpleLines([
      'curl -fsSL https://deb.nodesource.com/setup_19.x -o /tmp/node.sh',
      'sudo -E bash /tmp/node.sh',
      'sudo apt-get install -y nodejs',
    ]),
    check: CheckByCmd(
      Cmd('node --version'),
      (stdout) => stdout.contains('v19'),
      muteCmdNotFound: true,
    ));

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

final installLatestVim = SetupByCmds("install latest vim",
    commands: Cmd.simpleLines([
      'sudo add-apt-repository ppa:jonathonf/vim',
      'sudo apt update',
      'sudo apt install -y vim',
    ]),
    check: CheckByCmd(
      Cmd('vim --version'),
      (stdout) => stdout.contains('Vi IMproved 9'),
      muteCmdNotFound: true,
    ));

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
