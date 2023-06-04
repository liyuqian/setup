import 'package:setup/setup.dart';
import 'package:setup/zsh.dart';

Future<void> main() async {
  await setVimInBashrc.apply();
  await installGit.apply();
  await gitConfig.apply();

  await installTmux.apply();
  await ohMyTmux.apply();
  await installXclip.apply();
  await downloadTmuxConfLocal.apply();

  await setUpZsh(kDotfileRootUrl);
}

const String kDotfileRootUrl =
    'https://raw.githubusercontent.com/liyuqian/setup/main/dotfiles';

final installGit = AptInstall('git');
final installTmux = AptInstall('tmux');
final installXclip = AptInstall('xclip');

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

final downloadTmuxConfLocal = DownloadFile(
  'download tmux.conf.local',
  path: '$home/.tmux.conf.local',
  url: '$kDotfileRootUrl/.tmux.conf.local',
  sha512Prefix: '2e91420b',
);
