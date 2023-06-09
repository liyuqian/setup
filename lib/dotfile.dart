import 'package:logger/logger.dart';
import 'package:setup/setup.dart';

const Map<String, String> kRelativePathToHash = {
  '.zshrc': '75a292e3',
  '.p10k.zsh': '7a066a31',
  '.tmux.conf.local': '2e91420b',
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