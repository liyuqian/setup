import 'package:logger/logger.dart';
import 'package:setup/setup.dart';

const Map<String, String> kRelativePathToHash = {
  '.zshrc': 'fd23131b',
  '.p10k.zsh': '7a066a31',
  '.tmux.conf.local': 'd9830edc',
  '.vim_runtime/my_configs.vim': '44d404ca',
  '.vim_runtime/my_plugins/coc_configs.vim': '1e5e28c0',
  '.vimrc': '44317ffe',
};

Future<void> downloadDotfiles(String dotfileRootUrl, {Logger? logger}) async {
  for (final relativePath in kRelativePathToHash.keys) {
    final downloadFile = DownloadFile(
      'download $relativePath',
      path: '$home/$relativePath',
      url: '$dotfileRootUrl/$relativePath',
      sha512Prefix: kRelativePathToHash[relativePath]!,
    );
    await downloadFile.apply(logger: logger);
  }
}
