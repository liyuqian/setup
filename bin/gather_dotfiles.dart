import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:setup/default.dart';
import 'package:setup/setup.dart';

void main() {
  final List<String> relativePaths = [
    '.vim_runtime/my_configs.vim',
    '.zshrc',
    '.tmux.conf.local',
    '.p10k.zsh',
  ];

  final String projectRoot = File(Platform.script.path).parent.parent.path;
  for (final relativePath in relativePaths) {
    final original = File('$home/$relativePath');
    final copy = File('$projectRoot/dotfiles/$relativePath');
    if (original.readAsStringSync() != copy.readAsStringSync()) {
      original.copySync(copy.path);
      final hash = sha512.convert(copy.readAsBytesSync()).toString();
      defaultLogger
          .i('copied $relativePath with hash prefix ${hash.substring(0, 8)}');
    }
  }
}
