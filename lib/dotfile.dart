import 'package:logger/logger.dart';
import 'package:setup/setup.dart';

const Map<String, String> kRelativePathToHash = {
  '.zshrc': '6e9c0fcf',
  '.p10k.zsh': '7a066a31',
  '.tmux.conf.local': '9a15ebee',
  '.vim_runtime/my_configs.vim': '6786a72e',
  '.vim_runtime/my_plugins/coc_configs.vim': '1e5e28c0',
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
