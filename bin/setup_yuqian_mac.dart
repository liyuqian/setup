import 'package:setup/dotfile.dart';
import 'package:setup/setup.dart';
import 'package:setup/shared.dart';
import 'package:setup/zsh.dart';

Future<void> main() async {
  await makeGitSetup("Yuqian Li", "liyuqian79@gmail.com").apply();

  await BrewInstall('tmux').apply();
  await ohMyTmux.apply();

  // Maybe this is only needed for X11 linux?
  // await installXclip.apply();

  await setUpZshMac();

  // Tile manager
  await BrewInstall('rectangle').apply();

  // CPU/GPU/temperature
  await BrewInstall('stats').apply();

  // Allow option key to be used as Meta key for tmux
  await BrewInstall('iterm2').apply();

  await BrewInstall('node').apply();

  await ultimateVimrc.apply();
  await ctrlpVimPlugin.apply();
  await dartVimPlugin.apply();
  await fzfPlugin.apply();
  await fzfVimPlugin.apply();
  await cocVimPlugin.apply();

  const String kDotfileRootUrl =
      'https://raw.githubusercontent.com/liyuqian/setup/main/dotfiles';
  await downloadDotfiles(kDotfileRootUrl);
}
