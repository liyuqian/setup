import 'package:logger/logger.dart';
import 'package:setup/collection.dart';

const Map<String, String> kRelativePathToHash = {
  '.zshrc': 'd4e83e6e',
  '.p10k.zsh': '0651591e',
  '.tmux.conf.local': 'd9830edc',
  '.vim_runtime/my_configs.vim': '44d404ca',
  '.vim_runtime/my_plugins/coc_configs.vim': '1e5e28c0',
  '.vimrc': '3b619dc5',
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
