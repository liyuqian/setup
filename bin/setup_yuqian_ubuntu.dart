import 'package:setup/dotfile.dart';
import 'package:setup/setup.dart';
import 'package:setup/shared.dart';
import 'package:setup/zsh.dart';

Future<void> main() async {
  await setVimInBashrc.apply();
  await installGit.apply();
  await makeGitSetup("Yuqian Li", "liyuqian79@gmail.com").apply();

  await installTmux.apply();
  await ohMyTmux.apply();
  await installXclip.apply();

  await setUpZshUbuntu();

  await installNode22.apply();

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

final installNode22 = SetupByCmds('Install nodejs 22',
    commands: Cmd.simpleLines([
      'curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/node.sh',
      'sudo -E bash /tmp/node.sh',
      'sudo apt-get install -y nodejs',
    ]),
    check: CheckByCmd(
      Cmd('node --version'),
      (stdout) => stdout.contains('v22'),
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
