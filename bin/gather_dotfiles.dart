import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:setup/collection.dart';

void main() {
  final String projectRoot = File(Platform.script.path).parent.parent.path;
  for (final relativePath in kRelativePathToHash.keys) {
    final original = File('$home/$relativePath');
    final copy = File('$projectRoot/dotfiles/$relativePath');
    final hash =
        sha512.convert(original.readAsBytesSync()).toString().substring(0, 8);
    if (!copy.existsSync()) {
      copy.parent.createSync(recursive: true);
      copy.writeAsStringSync('to be replaced');
    }
    if (original.readAsStringSync() != copy.readAsStringSync()) {
      original.copySync(copy.path);
      defaultLogger.i('copied $relativePath with hash prefix $hash');
    } else {
      defaultLogger.i('No need to copy $relativePath');
      if (hash != kRelativePathToHash[relativePath]) {
        defaultLogger
            .e('Hash mismatch $hash != ${kRelativePathToHash[relativePath]} '
                'for $relativePath');
      }
    }
  }
}
